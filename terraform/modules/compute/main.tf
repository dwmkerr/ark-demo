# Single Graviton node running k3s. Amazon Linux 2023 (arm64) ships the AWS CLI
# and SSM agent, which cloud-init uses to publish the kubeconfig.

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_ssm_parameter" "kubeconfig" {
  name  = "/${var.name}/kubeconfig"
  type  = "SecureString"
  value = "pending" # cloud-init overwrites this once k3s is up.

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name               = "${var.name}-node"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Just enough to publish the kubeconfig parameter.
data "aws_iam_policy_document" "node" {
  statement {
    actions   = ["ssm:PutParameter"]
    resources = [aws_ssm_parameter.kubeconfig.arn]
  }
}

resource "aws_iam_role_policy" "node" {
  role   = aws_iam_role.node.id
  policy = data.aws_iam_policy_document.node.json
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.name}-node"
  role = aws_iam_role.node.name
}

resource "aws_instance" "node" {
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.node.name

  root_block_device {
    volume_size = var.disk_gb
    volume_type = "gp3"
  }

  # Spot is ~3x cheaper but can be reclaimed; toggle per environment.
  dynamic "instance_market_options" {
    for_each = var.use_spot ? [1] : []
    content {
      market_type = "spot"
    }
  }

  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    public_ip = var.node_public_ip
    region    = var.region
    ssm_param = aws_ssm_parameter.kubeconfig.name
    k3s_token = var.k3s_token
  })

  tags = { Name = "${var.name}-node" }
}

resource "aws_eip_association" "node" {
  instance_id   = aws_instance.node.id
  allocation_id = var.eip_allocation_id
}

# Block apply from reaching the ark module until cloud-init has published a real
# kubeconfig, so the providers downstream read valid creds.
resource "null_resource" "wait_for_kubeconfig" {
  depends_on = [aws_instance.node, aws_eip_association.node]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      for i in $(seq 1 60); do
        v=$(aws ssm get-parameter --name "${aws_ssm_parameter.kubeconfig.name}" \
          --with-decryption --region "${var.region}" \
          --query Parameter.Value --output text 2>/dev/null || true)
        if [ -n "$v" ] && [ "$v" != "pending" ]; then echo "kubeconfig ready"; exit 0; fi
        echo "waiting for k3s ($i/60)..."; sleep 10
      done
      echo "timed out waiting for kubeconfig"; exit 1
    EOT
  }
}
