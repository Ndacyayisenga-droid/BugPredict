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
  echo "🔄 Cloning $repo ..."
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

  echo "📊 Running Bugspots for $repo_name ..."
  cd "$WORKDIR/$repo_name"
  echo "Executing: git bugspots -w fix" >&2
  # Run bugspots and capture output to a temporary file
  temp_output=$(mktemp)
  if ! git bugspots -w fix > "$temp_output" 2> "$OUTPUT_DIR/bugspots-${repo_name}.err"; then
    echo "Error: Bugspots failed for $repo_name. Check $OUTPUT_DIR/bugspots-${repo_name}.err" >&2
    cat "$OUTPUT_DIR/bugspots-${repo_name}.err" >&2
    cd - > /dev/null
    continue
  fi

  # Filter top 20 bugfix commits and top 20 hotspots
  output_file="$OUTPUT_DIR/bugspots-${repo_name}.log"
  echo "Scanning $repo repo" > "$output_file"
  # Extract number of fixes and hotspots
  fixes_count=$(grep -c "^\s*- " "$temp_output")
  hotspots_count=$(grep -c "^\s*[0-9]\+\.[0-9]\+ - " "$temp_output")
  echo -e "\tFound $fixes_count bugfix commits, with $hotspots_count hotspots:\n" >> "$output_file"
  echo "Fixes:" >> "$output_file"
  # Extract top 20 bugfix commits
  grep "^\s*- " "$temp_output" | head -n 20 | sed 's/^\t//' >> "$output_file"
  echo -e "\nHotspots:" >> "$output_file"
  # Extract top 20 hotspots (sorted by score, descending)
  grep "^\s*[0-9]\+\.[0-9]\+ - " "$temp_output" | sort -k1 -nr | head -n 20 | sed 's/^\t//' >> "$output_file"

  echo "Results saved to $output_file"
  rm -f "$temp_output"
  cd - > /dev/null
done

# Clean up temporary directories
rm -rf "$WORKDIR"

echo "✅ Bugspots analysis complete at $(date '+%Y-%m-%d %H:%M:%S %Z')."
