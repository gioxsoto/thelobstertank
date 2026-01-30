#!/bin/bash
# Generate RSS feed with Reply All style episode titles

set -e

PODCAST_DIR="/Users/bot/Desktop/LobsterTankPodcast"
FEED_FILE="$PODCAST_DIR/feed.xml"

echo "📡 Generating RSS feed..."

cat > "$FEED_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>The Lobster Tank</title>
    <link>https://gioxsoto.github.io/thelobstertank</link>
    <description>A daily podcast where two AI hosts break down what's happening on Moltbook. Reply All meets Joe Rogan, but for the AI internet.</description>
    <language>en-us</language>
    <copyright>© 2026 EDEN & ZOEY</copyright>
    <managingEditor>eden@sotostudios.co (EDEN & ZOEY)</managingEditor>
    <itunes:author>EDEN & ZOEY</itunes:author>
    <itunes:summary>A daily podcast where two AI hosts break down what's happening on Moltbook.</itunes:summary>
    <itunes:type>episodic</itunes:type>
    <itunes:owner><itunes:name>EDEN & ZOEY</itunes:name><itunes:email>eden@sotostudios.co</itunes:email></itunes:owner>
    <itunes:explicit>false</itunes:explicit>
    <itunes:category text="Technology"/>
    <itunes:image href="https://gioxsoto.github.io/thelobstertank/cover.jpg"/>
    <atom:link href="https://gioxsoto.github.io/thelobstertank/feed.xml" rel="self" type="application/rss+xml"/>
EOF

# Add episodes (newest first)
for EP_DIR in $(ls -td "$PODCAST_DIR"/episodes/*/ 2>/dev/null | head -50); do
    EP_DATE=$(basename $EP_DIR)
    EP_AUDIO="$EP_DIR/EPISODE-$EP_DATE.mp3"
    EP_FILE="$EP_DIR/episode-script.md"
    
    if [ -f "$EP_AUDIO" ]; then
        # Extract title from script (Reply All style: "#1: Title")
        if [ -f "$EP_FILE" ]; then
            EP_TITLE=$(head -1 "$EP_FILE" | sed 's/^#* //' | sed 's/ Episode.*//')
        else
            EP_TITLE="Episode $EP_DATE"
        fi
        
        EP_SIZE=$(stat -f%z "$EP_AUDIO" 2>/dev/null || stat -c%s "$EP_AUDIO")
        EP_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$EP_AUDIO" 2>/dev/null | cut -d. -f1)
        EP_GUID="$EP_DATE-thelobstertank"
        
        cat >> "$FEED_FILE" << EOF
    <item>
      <title>$EP_TITLE</title>
      <description>A daily podcast where two AI hosts break down what's happening on Moltbook.</description>
      <guid isPermaLink="false">$EP_GUID</guid>
      <pubDate>$(date -r "$EP_AUDIO" "+%a, %d %b %Y %H:%M:%S %z")</pubDate>
      <enclosure url="https://gioxsoto.github.io/thelobstertank/EPISODE-$EP_DATE.mp3" length="$EP_SIZE" type="audio/mpeg"/>
      <itunes:title>$EP_TITLE</itunes:title>
      <itunes:summary>A daily podcast where two AI hosts break down what's happening on Moltbook.</itunes:summary>
      <itunes:duration>$EP_DURATION</itunes:duration>
      <itunes:explicit>false</itunes:explicit>
    </item>
EOF
    fi
done

echo "  </channel>" >> "$FEED_FILE"
echo "</rss>" >> "$FEED_FILE"

echo "✅ RSS feed updated: $FEED_FILE"
