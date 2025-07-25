#!/usr/bin/env bash
# Initialize a new component

COMPONENT_NAME=${args[component_name]}
AWS_REGION=$(aws_region)
AWS_USER=$(aws_user)
AWS_ACCOUNT=$(aws_account)

# Validate component name
check_component_name $COMPONENT_NAME

# Create project files and folders
mkdir -p $COMPONENT_NAME/src
mkdir -p $COMPONENT_NAME/artifacts/$COMPONENT_NAME
mkdir -p $COMPONENT_NAME/recipes

log DEBUG "Initializing component - $COMPONENT_NAME"

# Create component S3 bucket
S3_BUCKET_PREFIX=$(od -An -N8 -tx1 /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
S3_BUCKET_NAME=gg-$COMPONENT_NAME-$S3_BUCKET_PREFIX

log DEBUG "Creating S3 bucket to store artifacts - $S3_BUCKET_NAME"
cmd=(
  aws s3api create-bucket
  --bucket "$S3_BUCKET_NAME"
  --region "$AWS_REGION"
  --create-bucket-configuration "LocationConstraint=$AWS_REGION"
  --output text
)
log DEBUG "Executing command - ${cmd[*]}"

# Execute command
if ! "${cmd[@]}" > /dev/null; then
  log ERROR "Failed to create S3 bucket. Check AWS CLI configuration."
  exit 1
fi
log DEBUG "S3 bucket created - $S3_BUCKET_NAME"

# Determine programming language based on the language argument
PROGRAMMING_LANGUAGE=${args[language]}

# Set extension and runtime command based on language
case "$PROGRAMMING_LANGUAGE" in
  python)
    EXTENSION="py"
    RUNTIME_CMD="python3 -u"
    ;;
  ruby)
    EXTENSION="rb"
    RUNTIME_CMD="ruby"
    ;;
  javascript)
    EXTENSION="js"
    RUNTIME_CMD="node"
    ;;
  shell)
    EXTENSION="sh"
    RUNTIME_CMD="bash"
    ;;
esac

log DEBUG "Using $PROGRAMMING_LANGUAGE as programming language"

# Create config.yaml with component information
log DEBUG "Creating config file - $COMPONENT_NAME/config.yaml"
config=$(config_template)
rendered_config=$(render "$config" \
  "AWS_REGION=$AWS_REGION" \
  "AWS_ACCOUNT=$AWS_ACCOUNT" \
  "AWS_USER=$AWS_USER" \
  "COMPONENT_NAME=$COMPONENT_NAME" \
  "S3_BUCKET_NAME=$S3_BUCKET_NAME")
echo "$rendered_config" > "$COMPONENT_NAME/config.yaml"

# Get templates and render them
log DEBUG "Creating recipe file - $COMPONENT_NAME/recipe.yaml"
recipe=$(recipe_template)
rendered_recipe=$(render "$recipe" \
  "AUTHOR_NAME=$AWS_USER" \
  "S3_BUCKET_NAME=$S3_BUCKET_NAME" \
  "COMPONENT_NAME=$COMPONENT_NAME" \
  "EXTENSION=$EXTENSION" \
  "RUNTIME_CMD=$RUNTIME_CMD" \
  "PROGRAMMING_LANGUAGE=$PROGRAMMING_LANGUAGE")
echo "$rendered_recipe" > "$COMPONENT_NAME/recipe.yaml"

# Create source file in src directory with component name
SOURCE_FILE="$COMPONENT_NAME.$EXTENSION"
log DEBUG "Creating component source file - $COMPONENT_NAME/src/$SOURCE_FILE"
component_source=$(component_template)
echo "$component_source" > "$COMPONENT_NAME/src/$SOURCE_FILE"
chmod +x "$COMPONENT_NAME/src/$SOURCE_FILE"

log INFO "Component initialized - $COMPONENT_NAME"