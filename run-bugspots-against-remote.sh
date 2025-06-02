#!/bin/bash

set -e

WORKDIR="bugspots-work-$(date +%s)"
REPOS=(
  "https://github.com/adoptium/aqa-tests.git"
  "https://github.com/eclipse-openj9/openj9.git"
)

# Check if bugspots is installed
if ! gem list bugspots -i > /dev/null; then
  echo "Installing bugspots gem..."
  gem install bugspots
fi

# Create working directory
mkdir -p "$WORKDIR"

for repo in "${REPOS[@]}"; do
  echo "🔄 Cloning $repo ..."
  repo_name=$(basename "$repo" .git)
  if ! git clone "$repo" "$WORKDIR/$repo_name"; then
    echo "Error: Failed to clone $repo"
    continue
  fi

  # Verify repository
  if [ ! -d "$WORKDIR/$repo_name/.git" ]; then
    echo "Error: $repo_name is not a valid Git repository"
    continue
  fi

  echo "📊 Running Bugspots for $repo_name ..."
  cd "$WORKDIR/$repo_name"
  if ! git bugspots -d 500 > "../../bugspots-${repo_name}.log" 2> "../../bugspots-${repo_name}.err"; then
    echo "Error: Bugspots failed for $repo_name. Check bugspots-${repo_name}.err"
  else
    echo "Results saved to bugspots-${repo_name}.log"
  fi
  cd - > /dev/null
done

echo "✅ Bugspots analysis complete."