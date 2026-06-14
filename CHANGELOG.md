# Changelog

## [0.1.8](https://github.com/dwmkerr/ark-demo/compare/v0.1.7...v0.1.8) (2026-06-14)


### Features

* add demo team to access allowlist with nuanced RBAC ([#49](https://github.com/dwmkerr/ark-demo/issues/49)) ([457d630](https://github.com/dwmkerr/ark-demo/commit/457d6307baa3fb33443b3814d6f818a20c513732))
* add Notion MCP + note-taker agent and Claude Agent SDK developer agents ([#33](https://github.com/dwmkerr/ark-demo/issues/33)) ([20b0d86](https://github.com/dwmkerr/ark-demo/commit/20b0d8692fa52fb843d3e67be0a470a961c221c3))
* add shellwright MCP server and path fix for Ark v0.1.49 ([#29](https://github.com/dwmkerr/ark-demo/issues/29)) ([817210a](https://github.com/dwmkerr/ark-demo/commit/817210ae92ea0d9a448086a28a2a455c29738cf1))
* allow manual dispatch of terraform-apply ([#41](https://github.com/dwmkerr/ark-demo/issues/41)) ([f12b297](https://github.com/dwmkerr/ark-demo/commit/f12b297fbb46bff8f4c3ccf69d665cb393c56c66))
* ark-api image override for JWKS hotfix ([#2321](https://github.com/dwmkerr/ark-demo/issues/2321)) ([#45](https://github.com/dwmkerr/ark-demo/issues/45)) ([2743316](https://github.com/dwmkerr/ark-demo/commit/274331676640052ecb7f482265d1ddfb1a128ae8))
* ark-dashboard image override for SSO cookie hotfix ([#2318](https://github.com/dwmkerr/ark-demo/issues/2318)) ([#44](https://github.com/dwmkerr/ark-demo/issues/44)) ([bee7c82](https://github.com/dwmkerr/ark-demo/commit/bee7c8296e22ba28bb0ae845f4ce47400f66403d))
* demo access allowlist as committed YAML ([#47](https://github.com/dwmkerr/ark-demo/issues/47)) ([8ed8062](https://github.com/dwmkerr/ark-demo/commit/8ed8062572fb7083788dd1dfbfaad095fbfb50b2))
* fork charts for ark-api/dashboard (impersonation) ([#46](https://github.com/dwmkerr/ark-demo/issues/46)) ([08ab57d](https://github.com/dwmkerr/ark-demo/commit/08ab57d34b7a29352b83355dc263ba39bdfc076c))
* GitHub SSO via Dex + per-user RBAC ([#42](https://github.com/dwmkerr/ark-demo/issues/42)) ([dc3576e](https://github.com/dwmkerr/ark-demo/commit/dc3576e86b3101bc88d88fdbd7b9a4685d9737e8))
* OpenAI responses demos ([#32](https://github.com/dwmkerr/ark-demo/issues/32)) ([ca288f7](https://github.com/dwmkerr/ark-demo/commit/ca288f78915069768f3f12ee36b219fe280ad243))
* reviewable plan + gated apply jobs ([#37](https://github.com/dwmkerr/ark-demo/issues/37)) ([66c323a](https://github.com/dwmkerr/ark-demo/commit/66c323a87b426dfa93fc4fd9deec42120ec44bf2))
* skip default model if it already exists in cluster ([#31](https://github.com/dwmkerr/ark-demo/issues/31)) ([1fb2eb5](https://github.com/dwmkerr/ark-demo/commit/1fb2eb565ff14dc864a8eeb7373add6d8fd255a3))
* terraform demo environment with plan/apply pipeline ([#34](https://github.com/dwmkerr/ark-demo/issues/34)) ([d211f5b](https://github.com/dwmkerr/ark-demo/commit/d211f5b3bf03b5edd5b1debc2aba86c66e7fb044))


### Bug Fixes

* anthropic-only demo with default + claude-4-opus models ([#39](https://github.com/dwmkerr/ark-demo/issues/39)) ([07a09da](https://github.com/dwmkerr/ark-demo/commit/07a09da53c9a4aa6aafc79d123cc66770fc72ab1))
* ark-api/dashboard env injection (full lists) ([#43](https://github.com/dwmkerr/ark-demo/issues/43)) ([101e79e](https://github.com/dwmkerr/ark-demo/commit/101e79e550fc30d6b8d4524a48c56e07ba0bac6d))
* build chart OCI deps in CI, disable helm provider dep resolution ([#36](https://github.com/dwmkerr/ark-demo/issues/36)) ([3b6c935](https://github.com/dwmkerr/ark-demo/commit/3b6c9355bb9e4e06ca3cf248d7cf225534ce178d))
* grant events read to demo roles ([#48](https://github.com/dwmkerr/ark-demo/issues/48)) ([37c83de](https://github.com/dwmkerr/ark-demo/commit/37c83deacc2442b407677730319f3ecd2185ba72))
* make SSH optional so CI apply needs no admin_cidrs ([#35](https://github.com/dwmkerr/ark-demo/issues/35)) ([7064ce5](https://github.com/dwmkerr/ark-demo/commit/7064ce53db2ea721444168d92639762d35030bde))
* supply ark-demo chart a values file ([#38](https://github.com/dwmkerr/ark-demo/issues/38)) ([545a916](https://github.com/dwmkerr/ark-demo/commit/545a9165b5b2b8ecfa0e662fea71d6af0459d800))
* use current Claude 4 model ids ([#40](https://github.com/dwmkerr/ark-demo/issues/40)) ([d105e4e](https://github.com/dwmkerr/ark-demo/commit/d105e4e3f96529459d6c93beb4034f74418d462d))

## [0.1.7](https://github.com/dwmkerr/ark-demo/compare/v0.1.6...v0.1.7) (2025-12-22)


### Features

* add AWS Knowledge and Microsoft Learn MCP servers ([#23](https://github.com/dwmkerr/ark-demo/issues/23)) ([b1ab9aa](https://github.com/dwmkerr/ark-demo/commit/b1ab9aa1f0716ea436ccc7e8af4cc1612bb57786))
* add issue resolution workflow demo ([#24](https://github.com/dwmkerr/ark-demo/issues/24)) ([774e058](https://github.com/dwmkerr/ark-demo/commit/774e058236d808e58a3aa4ed5f214ddfdaf6b2a1))
* add planning step and token validation to workflows ([#26](https://github.com/dwmkerr/ark-demo/issues/26)) ([ea99c95](https://github.com/dwmkerr/ark-demo/commit/ea99c956793fd4128a7fe6aeadd6005327fdda5b))
* add sync-issues workflow for copying issues to working repo ([#27](https://github.com/dwmkerr/ark-demo/issues/27)) ([b4c8e2c](https://github.com/dwmkerr/ark-demo/commit/b4c8e2c25727c860809ca15e6f83559fc3a0443c))
* align demos with ARK patterns ([#20](https://github.com/dwmkerr/ark-demo/issues/20)) ([7d0895c](https://github.com/dwmkerr/ark-demo/commit/7d0895cc7a8d28ba7ca3c1f80607516572ba0566))


### Bug Fixes

* add MCP server path for Ark v0.1.49 compatibility ([#28](https://github.com/dwmkerr/ark-demo/issues/28)) ([ec87d49](https://github.com/dwmkerr/ark-demo/commit/ec87d493a908a0af3e5aaaf33aba1547048956c5))
* resolve merge conflict - keep dwmkerr-ark-demo as release name ([2e8517e](https://github.com/dwmkerr/ark-demo/commit/2e8517e2676de31d84f541a900e8d388a7799d38))
* use dwmkerr-ark-demo as helm release name in Makefile ([0705f71](https://github.com/dwmkerr/ark-demo/commit/0705f713548c46140ac5b19714a96f660a4fec5f))

## [0.1.6](https://github.com/dwmkerr/ark-demo/compare/v0.1.5...v0.1.6) (2025-10-29)


### Bug Fixes

* rename helm chart from dwmkerr-starter-kit to ark-demo ([#17](https://github.com/dwmkerr/ark-demo/issues/17)) ([67b2380](https://github.com/dwmkerr/ark-demo/commit/67b238042473c17dff2af256c1ae9c7c3a4253b4))

## [0.1.5](https://github.com/dwmkerr/dwmkerr-ark-demo/compare/v0.1.4...v0.1.5) (2025-10-29)


### Features

* add lead software engineer, engineering team, and agents-as-tools pattern ([36de26a](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/36de26a328e70cedc5017fc1d2c2515f227aead0))
* add lead software engineer, engineering team, and agents-as-tools pattern ([#16](https://github.com/dwmkerr/dwmkerr-ark-demo/issues/16)) ([a99b793](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/a99b7937956e2b884670a3f5fffce3d742e55d45))


### Bug Fixes

* update pr-review workflow for minio tls and tool names ([3f4e636](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/3f4e636e6aff8b48ccf2a7276ab3b948b6fd3e06))
* update pr-review workflow for minio tls and tool names ([#14](https://github.com/dwmkerr/dwmkerr-ark-demo/issues/14)) ([29f0fe3](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/29f0fe388326bf79f567e7980dbf5285c177e9ee))

## [0.1.4](https://github.com/dwmkerr/dwmkerr-ark-demo/compare/v0.1.3...v0.1.4) (2025-10-08)


### Features

* move github-mcp to standalone chart with multi-arch support ([#12](https://github.com/dwmkerr/dwmkerr-ark-demo/issues/12)) ([10c0ae4](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/10c0ae4129a0cec989cbd331ad8ca82c48c1229a))

## [0.1.3](https://github.com/dwmkerr/dwmkerr-ark-demo/compare/v0.1.2...v0.1.3) (2025-10-08)


### Features

* rename shell to shell-mcp and add MCP servers build matrix ([#10](https://github.com/dwmkerr/dwmkerr-ark-demo/issues/10)) ([c578587](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/c578587703b785ae1172fd26de970ddb128a8a92))

## [0.1.2](https://github.com/dwmkerr/dwmkerr-ark-demo/compare/v0.1.1...v0.1.2) (2025-10-03)


### Bug Fixes

* update helm dependencies before packaging in cicd ([8481834](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/8481834c6996795244277860c6d2b8b36aa30ac8))

## [0.1.1](https://github.com/dwmkerr/dwmkerr-ark-demo/compare/v0.1.0...v0.1.1) (2025-10-03)


### Features

* add automatic dashboard icons for agents based on model provider ([135a32d](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/135a32d9dd05daceb9ad46e6994b7ee35873d87b))
* add automatic dashboard icons for agents based on model provider ([8330190](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/83301908d26558a18a0aceacb74e756909616d91))
* add basic non-interactive ARK demo notebook ([30a1841](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/30a18414ac01f3a59c0c716c7345510f1db71ed0))
* Add GitHub MCP server and agent with comprehensive tools ([#3](https://github.com/dwmkerr/dwmkerr-ark-demo/issues/3)) ([df4d6d9](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/df4d6d9240c686b2c1bcee8a6e99d096b3fd93b1))
* Add interactive Jupyter notebook for ARK OpenAI API ([#4](https://github.com/dwmkerr/dwmkerr-ark-demo/issues/4)) ([ef400c8](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/ef400c8c70a5b517529210f398c6d3e5915b0306))


### Bug Fixes

* correct uninstall-all target name in Makefile ([497358d](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/497358dd58ca967985fb02fded204f21be811452))
* helm chart deployment bug and improve model configuration ([98f3967](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/98f3967dfa5e4cb79d54625d5132acdec7162269))
* mcp tools and notebook improvements ([b4bedd0](https://github.com/dwmkerr/dwmkerr-ark-demo/commit/b4bedd0f50805855782ab04cb0d1b9d22f57a05e))
