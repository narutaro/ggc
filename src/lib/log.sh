# Logging utilities

# Log messages with different levels and timestamp
log() {
  local level=$1
  shift
  local message="$*"

  local level_priority=0  
  local min_priority=0

  # level_priority
  case "$level" in
    DEBUG)  level_priority=1 ;;
    INFO)   level_priority=2 ;;
    WARN)   level_priority=3 ;;
    ERROR)  level_priority=4 ;;
    *) 
      echo "Invalid log level: $level"
      return 1
      ;;
  esac

  # Get message level from environment variable
  # Fallback to INFO if MESSAGE_LEVEL is not set
  case "${MESSAGE_LEVEL:-INFO}" in
    DEBUG)  min_priority=1 ;;
    INFO)   min_priority=2 ;;
    WARN)   min_priority=3 ;;
    ERROR)  min_priority=4 ;;
    *) 
      # If MESSAGE_LEVEL is invalid, default to INFO
      min_priority=2
      echo "Warning: Invalid MESSAGE_LEVEL '${MESSAGE_LEVEL}', using INFO instead"
      ;;
  esac

  local timestamp=$(date '+%Y-%m-%dT%H:%M:%S%z')

  # Compare level_priority with min_priority
  if [ "$level_priority" -ge "$min_priority" ]; then
    case "$level" in
      DEBUG)
        echo "$(blue "$timestamp [DEBUG] $message")"
        ;;
      INFO)
        echo "$(white "$message")"
        ;;
      WARN)
        echo "$(yellow "$message")"
        ;;
      ERROR)
        echo "$(red "$message")"
        ;;
    esac
  fi
}