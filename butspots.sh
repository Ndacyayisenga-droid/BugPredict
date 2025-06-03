#!/bin/bash

set -e

WORKDIR="bugspots-work-$(date +%s)"
REPOS=(
  "https://github.com/adoptium/aqa-tests.git"
  "https://github.com/eclipse-openj9/openj9.git"
)
OUTPUT_DIR="bugspots-results"

# Log current date and time (EAT)
echo "Running Bugspots script at $(date '+%Y-%m-%d %H:%M:%S %Z')"

# Check if bugspots is installed
if ! gem list bugspots -i > /dev/null; then
  echo "Installing bugspots gem..."
  gem install bugspots
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

for repo in "${REPOS[@]}"; do
  echo ":arrows_counterclockwise: Cloning $repo ..."
  repo_name=$(basename "$repo" .git)
  # Shallow clone with 1000 commits
  if ! git clone --branch master --depth 1000 "$repo" "$WORKDIR/$repo_name" 2> "$OUTPUT_DIR/bugspots-${repo_name}.clone.err"; then
    echo "Error: Failed to clone $repo" >&2
    cat "$OUTPUT_DIR/bugspots-${repo_name}.clone.err" >&2
    echo "Clone failed for $repo_name at $(date '+%Y-%m-%d %H:%M:%S %Z')" > "$OUTPUT_DIR/bugspots-${repo_name}.err"
    continue
  fi

  # Verify repository
  if [ ! -d "$WORKDIR/$repo_name/.git" ]; then
    echo "Error: $repo_name is not a valid Git repository" >&2
    echo "Invalid Git repository: $repo_name at $(date '+%Y-%m-%d %H:%M:%S %Z')" > "$OUTPUT_DIR/bugspots-${repo_name}.err"
    continue
  fi

  echo ":bar_chart: Running Bugspots for $repo_name ..."
  cd "$WORKDIR/$repo_name"
  echo "Executing: git bugspots -w fix" >&2
  if ! git bugspots -w fix > "../../$OUTPUT_DIR/bugspots-${repo_name}.log" 2> "../../$OUTPUT_DIR/bugspots-${repo_name}.err"; then
    echo "Error: Bugspots failed for $repo_name. Check $OUTPUT_DIR/bugspots-${repo_name}.err" >&2
    cat "../../$OUTPUT_DIR/bugspots-${repo_name}.err" >&2
  else
    echo "Results saved to $OUTPUT_DIR/bugspots-${repo_name}.log"
  fi
  cd - > /dev/null
done

# Clean up temporary directories
rm -rf "$WORKDIR"

echo ":white_check_mark: Bugspots analysis complete at $(date '+%Y-%m-%d %H:%M:%S %Z')."