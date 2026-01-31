#!/bin/bash
# Install The Lobster Tank cron job
# Run: bash /Users/bot/Desktop/LobsterTankPodcast/install-cron.sh

CRON_DIR="/Users/bot/Desktop/LobsterTankPodcast"
CRON_LINE="0 6 * * * cd $CRON_DIR && ./scripts/daily-episode.sh >> /Users/bot/clawd/logs/podcast.log 2>&1"

# Create log directory
mkdir -p /Users/bot/clawd/logs

# Write cron to file
echo "$CRON_LINE" > /Users/bot/.crontab-lobster

# Install
crontab /Users/bot/.crontab-lobster 2>/dev/null

# Verify
echo "=== Cron Installed ==="
crontab -l | grep daily-episode

echo ""
echo "=== To test run ==="
echo "cd $CRON_DIR && ./scripts/daily-episode.sh"
