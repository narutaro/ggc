# Template functions

# Get the content of the config.yaml template
config_template() {
  cat << 'EOF'
AwsRegion: AWS_REGION
AwsAccount: AWS_ACCOUNT
AwsUser: AWS_USER
ComponentName: COMPONENT_NAME
S3BucketName: S3_BUCKET_NAME
LastBuiltVersion: '0.0.0'
EOF
}

# Get the content of the recipe.yaml template
recipe_template() {  # No arguments needed
  cat << 'EOF'
RecipeFormatVersion: '2020-01-25'
ComponentName: COMPONENT_NAME
ComponentVersion: '0.0.0'
ComponentDescription: COMPONENT_NAME is a PROGRAMMING_LANGUAGE project.
ComponentPublisher: AUTHOR_NAME
ComponentConfiguration:
  DefaultConfiguration:
    Message: 'COMPONENT_NAME is written in PROGRAMMING_LANGUAGE'
Manifests:
  - Platform:
      os: linux
      runtime: '*'
    Artifacts:
      - Uri: s3://S3_BUCKET_NAME/artifacts/COMPONENT_NAME/0.0.0/files.zip
        Unarchive: ZIP
    Lifecycle:
      run: |
        RUNTIME_CMD {artifacts:decompressedPath}/files/COMPONENT_NAME.EXTENSION "{configuration:/Message}"
EOF
}

# Get the content of the component source file template
component_template() {
  # No arguments needed - generic template for any language
  cat << 'EOF'
# AWS IoT Greengrass Component Source File
#
# This file contains the code for your Greengrass component.
# Write your component code below using your selected programming language.
#
# Example (Python Hello World):
# ---------------------------
# import sys
# import time
#
# message = "Hello, I'm a Greengrass component - %s!" % sys.argv[1]
#
# while True:
#     print(message)
#     time.sleep(5)
#
# ---------------------------
#
# Your component code starts here:


EOF
}
