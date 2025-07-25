# AWS information utilities

# Get AWS region from AWS CLI configuration with error checking
aws_region() {
  local region

  # Try to get region from environment variables (AWS_REGION takes precedence)
  region="${AWS_REGION:-${AWS_DEFAULT_REGION}}"

  # If no environment variables are set, get from config file
  if [ -z "$region" ]; then
    region=$(aws configure get region)
  fi

  # If still no region found, exit with error
  if [ -z "$region" ]; then
    log ERROR "AWS region is not configured." >&2
    exit 1
  fi

  echo "$region"
}

# Get AWS account from AWS CLI configuration with error checking
aws_account() {
  local account=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
  if [ -z "$account" ]; then
    log ERROR "AWS account is not configured. Check if AWS credentials are set up." >&2
    exit 1
  fi
  echo "$account"
}

# Get AWS user from AWS CLI configuration with error checking
aws_user() {
  local user=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null | awk -F'/' '{print $NF}')
  if [ -z "$user" ]; then
    log ERROR "AWS user is not configured. Check if AWS credentials are set up." >&2
    exit 1
  fi
  echo "$user"
}