#
# Helpers for both `gen3` and `g3k`.
# Test with `gen3 testsuite` - see ../bin/testsuite.sh 
#

_UTILS_GEN3=$(dirname -- "$(readlink -f -- "${BASH_SOURCE:-$0}")")

export XDG_DATA_HOME=${XDG_DATA_HOME:-~/.local/share}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-"/tmp/gen3-$USER"}
export GEN3_CACHE_DIR="${XDG_DATA_HOME}/gen3/cache"
export GEN3_ETC_FOLDER="${XDG_DATA_HOME}/gen3/etc"

(
  for path in "$GEN3_CACHE_DIR" "$GEN3_ETC_FOLDER/gcp"; do
    if [[ ! -d "$path" ]]; then
      mkdir -p -m 0700 "$path"
    fi
  done    
)

# MacOS has 'md5', linux has 'md5sum'
MD5=md5
if [[ $(uname -s) == "Linux" ]]; then
  MD5=md5sum
fi

if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
  mkdir -p -m 0700 "$XDG_RUNTIME_DIR"
fi

if [[ ! -d "$GEN3_CACHE_DIR" ]]; then
  mkdir -p -m 0700 "$GEN3_CACHE_DIR"
fi


#
# Little semver tester - returns true if a -gt b
# @param a semver str
# @param b semver str
# @return 0 if a >= b
#
semver_ge() {
  local aStr
  local bStr
  local aMajor
  local aMinor
  local aPatch
  local bMajor
  local bMinor
  local bPatch
  aStr=$1
  bStr=$2
  if [[ "$aStr" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    let aMajor=${BASH_REMATCH[1]}
    let aMinor=${BASH_REMATCH[2]}
    let aPatch=${BASH_REMATCH[3]}
  else
    echo "ERROR: invalid semver $aStr"
  fi
  if [[ "$bStr" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    let bMajor=${BASH_REMATCH[1]}
    let bMinor=${BASH_REMATCH[2]}
    let bPatch=${BASH_REMATCH[3]}
  else
    echo "ERROR: invalid semver $bStr"
  fi

  if [[ $aMajor -gt $bMajor || ($aMajor -eq $bMajor && $aMinor -gt $bMinor) || ($aMajor -eq $bMajor && $aMinor -eq $bMinor && $aPatch -ge $bPatch) ]]; then
    return 0
  else
    return 1
  fi
}

# vt100 escape sequences - don't forget to pass -e to 'echo -e'
RED_COLOR="\x1B[31m"
DEFAULT_COLOR="\x1B[39m"
GREEN_COLOR="\x1B[32m"

#
# Return red-escaped string suitable for passing to 'echo -e'
#
red_color() {
  echo "${RED_COLOR}$1${DEFAULT_COLOR}"
}

#
# Return green-escaped string suitable for passing to 'echo -e'
#
green_color() {
  echo "${GREEN_COLOR}$1${DEFAULT_COLOR}"
}

#
# Do not redefine these variables every time this file is sourced
# The idea is that all our scripts source utils.sh,
# then use gen3_load to source other scripts,
# so utils.sh may get sourced multiple times.
#
if [[ -z "${GEN3_SOURCED_SCRIPTS_GUARD}" ]]; then
  declare -A GEN3_SOURCED_SCRIPTS
  GEN3_SOURCED_SCRIPTS=( ["/gen3/lib/utils"]="${GEN3_HOME}/gen3/lib/utils.sh" )
  GEN3_SOURCED_SCRIPTS_GUARD="loaded"
fi


#
# Little helper for interactive debugging - 
# clears the GEN3_SOURCED_SCRIPTS flags,
# and re-source gen3setup.sh
#
gen3_reload() {
  GEN3_SOURCED_SCRIPTS=()
  GEN3_SOURCED_SCRIPTS_GUARD=""
  gen3_load "gen3/gen3setup.sh"
}

#
# Source ${GEN3_HOME}/${key}.sh
#   ex: gen3_load gen3/lib/gcp
#
gen3_load() {
  local key
  local path
  if [[ -z "$1" ]]; then
    echo -e "$(red_color "gen3_load passed empty script key")"
    return 1
  fi
  key=$(echo "/$1" | sed 's@///*@/@g' | sed 's/\.sh$//')
  if [[ key =~ \.\. ]]; then
    echo -e "$(red_color "gen3_load illegal key: $key")"
    return 1
  fi
  path="${GEN3_HOME}${key}.sh"
  if [[ -n "${GEN3_SOURCED_SCRIPTS["$key"]}" ]]; then
    # script already loaded
    #echo "Already loaded $key"
    return 0
  fi
  GEN3_SOURCED_SCRIPTS["$key"]="$path"
  if [[ ! -f "${path}" ]]; then
    echo -e "$(red_color "ERROR: gen3_load path does not exist: $path")"
    return 1
  fi
  #echo "Loading $key - $path"
  source "${path}"
}


#
# Let helper generates a random string of alphanumeric characters of length $1.
#
function random_alphanumeric() {
    base64 /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c "${1:-"32"}"
}
