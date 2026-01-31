# The Lobster Tank - Cron Setup
# Run this once to automate daily episodes at 6 AM

echo "0 6 * * * /Users/bot/Desktop/LobsterTankPodcast/scripts/daily-episode.sh >> /Users/bot/clawd/logs/podcast.log 2>&1" | crontab -

# Verify
crontab -l | grep daily-episode

# View logs
cat /Users/bot/clawd/logs/podcast.log
