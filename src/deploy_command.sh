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

cmd1=(
  sudo /greengrass/v2/bin/greengrass-cli
  deployment create
  --recipeDir recipes/
  --artifactDir artifacts/
  --merge "$COMPONENT_NAME=$COMPONENT_VERSION"
)

log DEBUG "Executing - ${cmd1[*]}"

if "${cmd1[@]}"; then
  log INFO "Deployed component $COMPONENT_NAME:$COMPONENT_VERSION"
else
  log ERROR "Failed to deploy $COMPONENT_NAME:$COMPONENT_VERSION"
fi