#!/usr/bin/env bash
# Display the latest component versions

# Read component information from config.yaml if no component name is provided
if [[ -z "${args[component_name]}" ]]; then
  eval $(yaml_load "config.yaml")
  COMPONENT_NAME=$ComponentName
  LAST_BUILT_VERSION=$LastBuiltVersion
else
  COMPONENT_NAME=${args[component_name]}
  LAST_BUILT_VERSION="N/A (external component)"
fi

# Get AWS region and account
AWS_REGION=$(aws_region)
AWS_ACCOUNT=$(aws_account)

# Get the latest version from AWS
log DEBUG "Checking versions for component: $COMPONENT_NAME"

# Construct the ARN
COMPONENT_ARN="arn:aws:greengrass:$AWS_REGION:$AWS_ACCOUNT:components:$COMPONENT_NAME"

# Command to list component versions
list_cmd=(
  aws greengrassv2 list-component-versions
  --arn "$COMPONENT_ARN"
  --output yaml
)
log DEBUG "Executing command - ${list_cmd[*]}"

# Execute the command
if ! list_result=$("${list_cmd[@]}" 2>&1); then
  log ERROR "Failed to list component versions: $list_result"
  exit 1
fi

# Extract the latest version from the result
LATEST_VERSION=$(echo "$list_result" | grep -m 1 "componentVersion:" | awk '{print $2}')

if [[ -z "$LATEST_VERSION" ]]; then
  LATEST_VERSION="Not found in AWS"
fi

# Display the versions
log INFO "Component versions:"
log INFO "  ComponentName: $COMPONENT_NAME"
log INFO "  LastBuiltVersion: $LAST_BUILT_VERSION"
log INFO "  LatestAwsVersion: $LATEST_VERSION"

log DEBUG "Version check completed for $COMPONENT_NAME"