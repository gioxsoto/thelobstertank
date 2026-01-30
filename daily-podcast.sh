#!/bin/bash
# The Lobster Tank - Daily Episode Generator
# Usage: ./daily-podcast.sh [YYYY-MM-DD]

set -e

DATE=${1:-$(date +%Y-%m-%d)}
PODCAST_DIR="/Users/bot/Desktop/LobsterTankPodcast"
cd "$PODCAST_DIR"

echo "🎙️ The Lobster Tank - Day $DATE"
echo "================================"

# 1. Generate Episode
echo ""
echo "1️⃣ Generating episode..."
if [ -f "scripts/generate-episode-with-music.sh" ]; then
    ./scripts/generate-episode-with-music.sh $DATE
else
    echo "Script not found, skipping audio generation"
fi

# 2. Update RSS Feed
echo ""
echo "2️⃣ Updating RSS feed..."
if [ -f "scripts/generate-rss-feed.sh" ]; then
    ./scripts/generate-rss-feed.sh
else
    echo "RSS script not found, skipping"
fi

# 3. Commit & Deploy
echo ""
echo "3️⃣ Deploying..."
git add -A
git commit -m "Episode $DATE - $(date '+%B %d, %Y')"

if git remote get-url origin >/dev/null 2>&1; then
    git push origin main
    echo "✅ Deployed to GitHub Pages!"
else
    echo "⚠️ No origin remote. Run: git remote add origin https://github.com/YOURNAME/thelobstertank.git"
    echo "Then: git push -u origin main"
fi

echo ""
echo "🎉 Day $DATE complete!"
echo ""
echo "Next steps:"
echo "- Check episode: afplay episodes/$DATE/EPISODE-$DATE.mp3"
echo "- RSS feed: https://yourusername.github.io/thelobstertank/feed.xml"
