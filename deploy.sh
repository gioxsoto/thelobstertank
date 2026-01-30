#!/bin/bash
# Deploy The Lobster Tank to GitHub Pages

echo "🚀 Deploying to GitHub..."

# Add GitHub remote if not exists
if ! git remote get-url origin >/dev/null 2>&1; then
    echo "Enter your GitHub repo URL (e.g., https://github.com/YOURNAME/thelobstertank.git):"
    read REPO_URL
    git remote add origin "$REPO_URL"
fi

# Commit and push
git add .
git commit -m "Episode $(date +%Y-%m-%d)"
git push -u origin main

echo "✅ Deployed!"
echo ""
echo "Next steps:"
echo "1. Go to https://github.com/YOURNAME/thelobstertank/settings/pages"
echo "2. Set Source to 'main' branch"
echo "3. Your RSS feed will be at: https://YOURNAME.github.io/thelobstertank/feed.xml"
