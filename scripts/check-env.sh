#!/usr/bin/env bash

# Check for required environment variables for model providers
# Returns enabled providers and warns about missing keys

set -e

# Colors for output
red='\033[0;31m'
yellow='\033[1;33m'
green='\033[0;32m'
nc='\033[0m'

# Provider environment variables
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
AZURE_OPENAI_API_KEY="${AZURE_OPENAI_API_KEY:-}"
OPENAI_API_KEY="${OPENAI_API_KEY:-}"

# Track enabled providers
ENABLED_PROVIDERS=""
MISSING_KEYS=""

# Check each provider
if [ -n "$ANTHROPIC_API_KEY" ]; then
    ENABLED_PROVIDERS="$ENABLED_PROVIDERS anthropic"
    echo -e "${green}✓${nc} Anthropic API key found"
else
    MISSING_KEYS="$MISSING_KEYS ANTHROPIC_API_KEY"
fi

if [ -n "$GEMINI_API_KEY" ]; then
    ENABLED_PROVIDERS="$ENABLED_PROVIDERS gemini"
    echo -e "${green}✓${nc} Gemini API key found"
else
    MISSING_KEYS="$MISSING_KEYS GEMINI_API_KEY"
fi

if [ -n "$AZURE_OPENAI_API_KEY" ]; then
    ENABLED_PROVIDERS="$ENABLED_PROVIDERS azureOpenAI"
    echo -e "${green}✓${nc} Azure OpenAI API key found"
else
    MISSING_KEYS="$MISSING_KEYS AZURE_OPENAI_API_KEY"
fi

if [ -n "$OPENAI_API_KEY" ]; then
    ENABLED_PROVIDERS="$ENABLED_PROVIDERS openai"
    echo -e "${green}✓${nc} OpenAI API key found"
else
    MISSING_KEYS="$MISSING_KEYS OPENAI_API_KEY"
fi

# Warn about missing keys
if [ -n "$MISSING_KEYS" ]; then
    echo -e "${yellow}Warning:${nc} The following API keys are not set:"
    for key in $MISSING_KEYS; do
        echo -e "  ${yellow}•${nc} $key"
    done
    echo -e "${yellow}Note:${nc} Providers without API keys will be disabled"
fi

# Check if at least one provider is enabled
if [ -z "$ENABLED_PROVIDERS" ]; then
    echo -e "${red}Error:${nc} No API keys found. At least one provider must be configured."
    echo "Set one or more of: ANTHROPIC_API_KEY, GEMINI_API_KEY, AZURE_OPENAI_API_KEY, OPENAI_API_KEY"
    exit 1
fi

echo "Enabled providers:$ENABLED_PROVIDERS"