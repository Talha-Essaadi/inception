
#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="/home/ubuntu/inception"
BRANCH="main"
LOG_FILE="/home/ubuntu/github-backup.log"

exec >> "$LOG_FILE" 2>&1
echo "[$(date '+%F %T')] Checking for changes..."

cd "$REPO_DIR"

# Prevent overlapping runs
exec 9>/tmp/github-backup.lock
flock -n 9 || exit 0

# Ensure this is a Git repository
git rev-parse --is-inside-work-tree >/dev/null

# Stage tracked and untracked files, respecting .gitignore
git add -A

# Exit if there are no changes
if git diff --cached --quiet; then
    echo "No changes detected. Nothing to push."
    exit 0
fi

# Commit and push changes
git commit -m "Automatic backup: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin "$BRANCH"

echo "[$(date '+%F %T')] Changes pushed successfully."

