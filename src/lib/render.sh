# Template rendering utility

# Render a template string with variable substitution
# Usage: render TEMPLATE_STRING VAR1=VALUE1 VAR2=VALUE2 ...
render() {
  local template_content="$1"
  shift
  
  # Process each variable
  for var_pair in "$@"; do
    local var_name="${var_pair%%=*}"
    local var_value="${var_pair#*=}"
    
    # Replace all occurrences of the variable in the template
    template_content=${template_content//"$var_name"/"$var_value"}
  done
  
  # Output the rendered template
  echo "$template_content"
}