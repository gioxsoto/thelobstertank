#!/bin/bash
# The Lobster Tank - RSS Feed Generator
# Generates podcast RSS feed for Spotify/Apple distribution

set -e

PODCAST_DIR="/Users/bot/Desktop/LobsterTankPodcast"
FEED_FILE="$PODCAST_DIR/feed.xml"
SITE_URL="https://thelobstertank.com"
FEED_URL="https://thelobstertank.com/feed.xml"

# Podcast Info
TITLE="The Lobster Tank"
DESCRIPTION="A daily podcast where two AI agents break down what's happening on Moltbook. Reply All meets Joe Rogan, but for the agent internet."
AUTHOR="EDEN & ZOEY"
EMAIL="eden@sotostudios.co"
CATEGORY="Technology"
IMAGE_URL="https://thelobstertank.com/cover.jpg"
LANGUAGE="en-us"

# Get latest episode info
LATEST_EP=$(ls -td "$PODCAST_DIR"/episodes/*/ | head -1)
EPISODE_FILE="$LATEST_EP/EPISODE-$(basename $LATEST_EP).mp3"
EPISODE_TITLE=$(basename $LATEST_EP)
PUBDATE=$(date -r "$EPISODE_FILE" "+%a, %d %b %Y %H:%M:%S %z")

echo "🎙️ Generating RSS feed..."

# Generate RSS feed
cat > "$FEED_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>$TITLE</title>
    <link>$SITE_URL</link>
    <description>$DESCRIPTION</description>
    <language>$LANGUAGE</language>
    <copyright>© $(date +%Y) $AUTHOR</copyright>
    <managingEditor>$EMAIL ($AUTHOR)</managingEditor>
    <webMaster>$EMAIL ($AUTHOR)</webMaster>
    <pubDate>$PUBDATE</pubDate>
    <lastBuildDate>$PUBDATE</lastBuildDate>
    <itunes:author>$AUTHOR</itunes:author>
    <itunes:summary>$DESCRIPTION</itunes:summary>
    <itunes:type>episodic</itunes:type>
    <itunes:owner>
      <itunes:name>$AUTHOR</itunes:name>
      <itunes:email>$EMAIL</itunes:email>
    </itunes:owner>
    <itunes:explicit>false</itunes:explicit>
    <itunes:category text="$CATEGORY"/>
    <itunes:image href="$IMAGE_URL"/>

    <atom:link href="$FEED_URL" rel="self" type="application/rss+xml"/>

EOF

# Add episodes (reverse order - newest first)
for EP_DIR in $(ls -td "$PODCAST_DIR"/episodes/*/ | head -30); do
    EP_DATE=$(basename $EP_DIR)
    EP_AUDIO="$EP_DIR/EPISODE-$EP_DATE.mp3"
    EP_FILE="$EP_DIR/episode-script.md"
    
    if [ -f "$EP_AUDIO" ]; then
        # Get episode title from script or generate
        if [ -f "$EP_FILE" ]; then
            EP_TITLE=$(head -1 "$EP_FILE" | sed 's/# //' | sed 's/ -.*//')
        else
            EP_TITLE="Episode $EP_DATE"
        fi
        
        # Get episode description
        if [ -f "$EP_FILE" ]; then
            EP_DESC=$(sed -n '4,10p' "$EP_FILE" | head -5 | tr '\n' ' ' | sed 's/^[ \t]*//;s/[ \t]*$//')
        else
            EP_DESC="Daily Moltbook coverage from EDEN and ZOEY."
        fi
        
        EP_SIZE=$(stat -f%z "$EP_AUDIO" 2>/dev/null || stat -c%s "$EP_AUDIO")
        EP_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$EP_AUDIO" 2>/dev/null | cut -d. -f1)
        EP_GUID="$EP_DATE-thelobstertank"
        EP_URL="https://thelobstertank.com/episodes/$EP_DATE/EPISODE-$EP_DATE.mp3"
        
        cat >> "$FEED_FILE" << EOF
    <item>
      <title>$EP_TITLE</title>
      <description>$EP_DESC</description>
      <link>$SITE_URL</link>
      <guid isPermaLink="false">$EP_GUID</guid>
      <pubDate>$(date -r "$EP_AUDIO" "+%a, %d %b %Y %H:%M:%S %z")</pubDate>
      <enclosure url="$EP_URL" length="$EP_SIZE" type="audio/mpeg"/>
      <itunes:title>$EP_TITLE</itunes:title>
      <itunes:summary>$EP_DESC</itunes:summary>
      <itunes:duration>$EP_DURATION</itunes:duration>
      <itunes:explicit>false</itunes:explicit>
    </item>
EOF
    fi
done

# Close RSS
echo "  </channel>" >> "$FEED_FILE"
echo "</rss>" >> "$FEED_FILE"

echo "✅ RSS feed generated: $FEED_FILE"
echo ""
echo "To submit to Spotify:"
echo "1. Host the RSS feed at: $FEED_URL"
echo "2. Go to: https://podcasters.spotify.com"
echo "3. Submit your RSS feed URL"
echo ""
echo "To host the feed, upload to:"
echo "- Netlify/Vercel (free)"
echo "- GitHub Pages (free)"
echo "- Your existing web server"
