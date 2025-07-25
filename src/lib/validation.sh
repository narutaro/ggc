# Validation functions for component operations

# Validate semantic version format (X.Y.Z)
check_semantic_version() {
  local version="$1"
  local semver_regex="^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9A-Za-z.-]+))?(\+([0-9A-Za-z.-]+))?$"
  
  if [[ ! "$version" =~ $semver_regex ]]; then
    log ERROR "Invalid semantic version: $version"
    log ERROR "Version must be in format X.Y.Z (e.g., 1.0.0)"
    return 1
  fi
}

# Validate component name according to S3 bucket naming rules
check_component_name() {
  component_name="$1"
  # Component name is used for S3 bucket name. Check S3 bucket name requirements.
  
  # S3 bucket prefix and random suffix
  local prefix="gg-"
  local random_suffix_length=9  # 8 chars + 1 dash
  
  # Calculate maximum allowed component name length
  # S3 bucket name format: gg-{component_name}-{random_suffix}
  # Max S3 bucket name length is 63 characters
  local max_component_length=$((63 - ${#prefix} - random_suffix_length))
  
  # Check the length of the component name
  if [ ${#component_name} -lt 3 ]; then
    log ERROR "The component name must be at least 3 characters long."
    return 1
  fi
  
  if [ ${#component_name} -gt $max_component_length ]; then
    log ERROR "The component name must be at most $max_component_length characters long to ensure the S3 bucket name doesn't exceed 63 characters."
    return 1
  fi

  # Check if the component name only contains lowercase letters, numbers, and dashes
  if [[ ! "$component_name" =~ ^[a-z0-9-]+$ ]]; then
    log ERROR "The component name can only contain lowercase letters, numbers, and dashes."
    return 1
  fi

  # Check if the component name starts or ends with a dash
  if [[ "$component_name" == -* ]] || [[ "$component_name" == *- ]]; then
    log ERROR "The component name cannot start or end with a dash."
    return 1
  fi

  # Check if the component name is in an IP address format (only digits and dots)
  if [[ "$component_name" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log ERROR "The component name cannot be an IP address."
    return 1
  fi
}