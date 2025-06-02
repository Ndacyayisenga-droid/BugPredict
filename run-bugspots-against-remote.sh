#!/bin/bash

set -e

WORKDIR="bugspots-work-$(date +%s)"
REPOS=(
  "https://github.com/adoptium/aqa-tests.git"
  "https://github.com/eclipse-openj9/openj9.git"
)
OUTPUT_DIR="bugspots-results"

# Check if bugspots is installed
if ! gem list bugspots -i > /dev/null; then
  echo "Installing bugspots gem..."
  gem install bugspots
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

for repo in "${REPOS[@]}"; do
  echo "🔄 Cloning $repo ..."
  repo_name=$(basename "$repo" .git)
  if ! git clone "$repo" "$WORKDIR/$repo_name"; then
    echo "Error: Failed to clone $repo" >&2
    echo "Clone failed for $repo_name" > "$OUTPUT_DIR/bugspots-${repo_name}.err"
    continue
  fi

  # Verify repository
  if [ ! -d "$WORKDIR/$repo_name/.git" ]; then
    echo "Error: $repo_name is not a valid Git repository" >&2
    echo "Invalid Git repository: $repo_name" > "$OUTPUT_DIR/bugspots-${repo_name}.err"
    continue
  fi

  echo "📊 Running Bugspots for $repo_name ..."
  cd "$WORKDIR/$repo_name"
  if ! git bugspots -d 500 > "../../$OUTPUT_DIR/bugspots-${repo_name}.log" 2> "../../$OUTPUT_DIR/bugspots-${repo_name}.err"; then
    echo "Error: Bugspots failed for $repo_name. Check $OUTPUT_DIR/bugspots-${repo_name}.err" >&2
  else
    echo "Results saved to $OUTPUT_DIR/bugspots-${repo_name}.log"
  fi
  cd - > /dev/null
done

# Clean up temporary directories
rm -rf "$WORKDIR"

echo "✅ Bugspots analysis complete."