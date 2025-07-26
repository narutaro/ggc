# Cross-platform wrapper for `sed -i`
# On macOS (BSD sed), `-i` requires a backup suffix ('' for no backup).
# On Linux (GNU sed), `-i` can be used without a suffix.
sedi() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}
