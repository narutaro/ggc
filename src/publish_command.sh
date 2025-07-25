#!/usr/bin/env bash
# Upload the component artifacts and create component

# Read component information from YAML files
eval $(yaml_load "recipe.yaml")
eval $(yaml_load "config.yaml")

# Set variables from YAML content
COMPONENT_NAME=$ComponentName
S3_BUCKET_NAME=$S3BucketName
AWS_REGION=$AwsRegion
AWS_ACCOUNT=$AwsAccount
AWS_USER=$AwsUser

# Get component version from args or use LastBuiltVersion from config.yaml
COMPONENT_VERSION=${args[component_version]:-$LastBuiltVersion}
log DEBUG "Using component version - $COMPONENT_VERSION"

# Validate semantic version
check_semantic_version "$COMPONENT_VERSION" || exit 1

# Check if the component artifact exists
ARTIFACT_DIR="artifacts/$COMPONENT_NAME/$COMPONENT_VERSION"
LOCAL_FILE="$ARTIFACT_DIR/files.zip"
if [[ ! -f "$LOCAL_FILE" ]]; then
  log ERROR "Component artifact not found: $LOCAL_FILE. Run 'ggc build $COMPONENT_VERSION' first"
  exit 1
fi

# Step 1: Upload artifact to S3
log DEBUG "Uploading artifact to S3"
S3_PATH="s3://$S3_BUCKET_NAME/artifacts/$COMPONENT_NAME/$COMPONENT_VERSION/files.zip"
s3_cmd=(
  aws s3 cp
  "$LOCAL_FILE"
  "$S3_PATH"
  --quiet
)
log DEBUG "Executing command - ${s3_cmd[*]}"

# Execute command and suppress output unless there's an error
if ! "${s3_cmd[@]}" > /dev/null 2>&1; then
  log ERROR "Failed to upload artifact to S3"
  exit 1
fi

log DEBUG "Artifact uploaded to S3"

# Step 2: Create component version
log DEBUG "Creating component version - $COMPONENT_NAME:$COMPONENT_VERSION"

# Use the version-specific recipe file
RECIPE_FILE="recipes/recipe-$COMPONENT_VERSION.yaml"
log DEBUG "Using version-specific recipe file - $RECIPE_FILE"

# Check if the recipe file exists
if [[ ! -f "$RECIPE_FILE" ]]; then
  log ERROR "Recipe file not found: $RECIPE_FILE. Run 'ggc build $COMPONENT_VERSION' first"
  exit 1
fi

# Create component version
create_cmd=(
  aws greengrassv2 create-component-version
  --inline-recipe "fileb://$RECIPE_FILE"
  --output yaml
)
log DEBUG "Executing command - ${create_cmd[*]}"

if ! create_result=$("${create_cmd[@]}" 2>&1); then
  log ERROR "Failed to create component version: $create_result"
  exit 1
fi

# Display the result
log DEBUG "Component created - $COMPONENT_NAME:$COMPONENT_VERSION"

# Show detailed result only in DEBUG mode
log DEBUG "Component creation result:\n\n$create_result\n"

# Step 3: Verify component creation
log DEBUG "Verifying component creation"
describe_cmd=(
  aws greengrassv2 describe-component
  --arn "arn:aws:greengrass:$AWS_REGION:$AWS_ACCOUNT:components:$COMPONENT_NAME:versions:$COMPONENT_VERSION"
  --output yaml
)
log DEBUG "Executing command - ${describe_cmd[*]}"

if ! describe_result=$("${describe_cmd[@]}" 2>&1); then
  log ERROR "Failed to verify component creation: $describe_result"
  exit 1
fi

# Display the result
log DEBUG "Component verified - $COMPONENT_NAME:$COMPONENT_VERSION"

# Show detailed result only in DEBUG mode
log DEBUG "Component verification result:\n\n$describe_result\n"

log INFO "Component published - $COMPONENT_NAME:$COMPONENT_VERSION"