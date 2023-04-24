#!/usr/bin/env sh
# deploys to wow addon directory

dev_dir="dev"
eval "cd ./${dev_dir}" || {
  echo "Failed to cd to ./${dev_dir} directory" && exit 0
}
pwd="$(basename $PWD)"

[ "${pwd}" = "${dev_dir}" ] || {
  echo "This script needs to run in ./${dev_dir} directory." \
    && echo "Current dir: ${PWD}" \
    && exit 0
}

# classic retail classic_era
./gradlew classic
