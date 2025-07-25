# Filters for command execution

filter_is_project_root() {
  # Check for required files and directories
  if [[ ! -f "config.yaml" || ! -f "recipe.yaml" || ! -d "src" || ! -d "artifacts" || ! -d "recipes" ]]; then
    echo "$(log ERROR "Run this command in a component directory")"
    return
  fi
  
  # Check if files are valid and not empty
  if [[ ! -s "config.yaml" || ! -s "recipe.yaml" ]]; then
    echo "$(log ERROR "Component configuration files cannot be empty")"
    return
  fi
  
  # Success - no output means filter passed
}