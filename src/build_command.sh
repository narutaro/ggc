#!/usr/bin/env bash
# Build the component and prepare its artifacts

COMPONENT_VERSION=${args[component_version]}

# Validate semantic version format
check_semantic_version "$COMPONENT_VERSION" || exit 1

# Read component information from YAML files
eval $(yaml_load "recipe.yaml")
eval $(yaml_load "config.yaml")

# Set variables from YAML content
COMPONENT_NAME=$ComponentName
S3_BUCKET_NAME=$S3BucketName
AWS_REGION=$AwsRegion
AWS_ACCOUNT=$AwsAccount
AWS_USER=$AwsUser

# Check if version already exists
ARTIFACT_DIR="artifacts/$COMPONENT_NAME/$COMPONENT_VERSION"
if [[ -d "$ARTIFACT_DIR" ]]; then
  log ERROR "Version $COMPONENT_VERSION already exists. Use a different version number."
  exit 1
fi

log DEBUG "Building component - $COMPONENT_NAME version $COMPONENT_VERSION"

# Update version in the recipe.yaml file
log DEBUG "Updating version references in recipe.yaml to $COMPONENT_VERSION"

# Update the ComponentVersion field
sedi "s/ComponentVersion:.*$/ComponentVersion: '$COMPONENT_VERSION'/" recipe.yaml


# Update S3 artifact paths - replace old version with new version in URI paths
# $ComponentVersion is the current version from recipe.yaml (loaded at the beginning)
# $COMPONENT_VERSION is the new version specified as command argument
# Only update S3 paths if current version exists and is different from the new version
if [[ -n "$ComponentVersion" && "$ComponentVersion" != "$COMPONENT_VERSION" ]]; then
  log DEBUG "Updating S3 paths from version $ComponentVersion to $COMPONENT_VERSION"
  # This replaces paths like s3://bucket/artifacts/component-name/0.1.0/ with s3://bucket/artifacts/component-name/0.2.0/
  sedi "s|/artifacts/$COMPONENT_NAME/$ComponentVersion/|/artifacts/$COMPONENT_NAME/$COMPONENT_VERSION/|g" recipe.yaml
fi

# Create version-specific recipe file
VERSION_RECIPE="recipes/recipe-$COMPONENT_VERSION.yaml"
log DEBUG "Copying recipe.yaml as $VERSION_RECIPE"
cp recipe.yaml "$VERSION_RECIPE"

# Create artifacts directory
ARTIFACT_DIR="artifacts/$COMPONENT_NAME/$COMPONENT_VERSION"
log DEBUG "Creating artifacts directory - $ARTIFACT_DIR"
mkdir -p $ARTIFACT_DIR

# Copy source files to artifacts directory
if [[ -d "src" && "$(ls -A src 2>/dev/null)" ]]; then
  log DEBUG "Copying source files from src directory"
  cp -r src/* "$ARTIFACT_DIR/"
  
  # Create zip file from copied files
  log DEBUG "Creating zip file - $ARTIFACT_DIR/files.zip"
  (cd "$ARTIFACT_DIR" && zip -rq files.zip *)
else
  log ERROR "No source files found in src directory"
  exit 1
fi

# Update LastBuiltVersion in config.yaml
log DEBUG "Updating LastBuiltVersion in config.yaml"
# LastBuiltVersion always exists in config.yaml template
# Using '.bak' extension for macOS/Linux cross-platform compatibility
sedi "s/^LastBuiltVersion:.*$/LastBuiltVersion: $COMPONENT_VERSION/" config.yaml

log INFO "Component built - $COMPONENT_NAME:$COMPONENT_VERSION"