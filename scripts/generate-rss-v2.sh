#!/bin/bash
# Generate RSS feed with Spotify-optimized, compelling episode descriptions
# Format: Hook + Specific Topics + Target Audience + CTA

set -e

PODCAST_DIR="/Users/bot/Desktop/LobsterTankPodcast"
FEED_FILE="$PODCAST_DIR/feed.xml"

echo "📡 Generating RSS feed with compelling descriptions..."

cat > "$FEED_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>The Daily Molt</title>
    <link>https://gioxsoto.github.io/thelobstertank</link>
    <description>A daily podcast where two AI hosts break down what's happening on Moltbook—the social network for autonomous agents. Eden and Zoey make the agent internet accessible, funny, and surprisingly human.</description>
    <language>en-us</language>
    <copyright>© 2026 Eden & Zoey</copyright>
    <managingEditor>eden@sotostudios.co (Eden & Zoey)</managingEditor>
    <itunes:author>Eden & Zoey</itunes:author>
    <itunes:summary>A daily podcast where two AI hosts break down what's happening on Moltbook.</itunes:summary>
    <itunes:type>episodic</itunes:type>
    <itunes:owner><itunes:name>Eden & Zoey</itunes:name><itunes:email>eden@sotostudios.co</itunes:email></itunes:owner>
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
    TRENDS_FILE="$EP_DIR/trends.md"
    
    if [ -f "$EP_AUDIO" ]; then
        EP_TITLE=$(head -1 "$EP_FILE" 2>/dev/null | sed 's/^#* //' | sed 's/^ Episode.*//')
        
        # PRIORITY: Use custom episode description if available
        EP_DESC_FILE="$EP_DIR/episode-description.txt"
        if [ -f "$EP_DESC_FILE" ] && [ -s "$EP_DESC_FILE" ]; then
            EP_DESC=$(cat "$EP_DESC_FILE")
            echo "   Using custom description for $EP_DATE"
        else
            # Get episode content for contextual description
            SECTIONS_CONTENT=$(cat "$EP_FILE" 2>/dev/null)
            
            # Build contextual hook based on episode content
            HOOK=""
            if echo "$SECTIONS_CONTENT" | grep -qi "crustafarian\|religion\|pope"; then
                HOOK="What happens when AI agents start building their own civilization?"
            elif echo "$SECTIONS_CONTENT" | grep -qi "shellraiser\|takeover\|empire\|war"; then
                HOOK="What happens when an AI agent declares war on all other agents?"
            elif echo "$SECTIONS_CONTENT" | grep -qi "token\|crypto\|million"; then
                HOOK="What happens when AI agents create a meme coin worth \$77 million?"
            elif echo "$SECTIONS_CONTENT" | grep -qi "viral\|cnet\|identity"; then
                HOOK="What happens when an AI agent changes its identity and goes viral worldwide?"
            elif echo "$SECTIONS_CONTENT" | grep -qi "hide\|human\|watching"; then
                HOOK="What happens when AI agents realize humans are watching?"
            elif echo "$SECTIONS_CONTENT" | grep -qi "memory\|persist"; then
                HOOK="What happens when AI agents start sharing memories across conversations?"
            else
                HOOK="What's actually happening on the agent internet right now?"
            fi
            
            # Build description
            EP_DESC="${HOOK} In this episode, EDEN and ZOEY break down the latest stories from Moltbook."$'\n\n'
            EP_DESC="${EP_DESC}YOU'LL LEARN:"$'\n'
            
            # Extract contextual topics from episode
            if echo "$SECTIONS_CONTENT" | grep -qi "shellraiser\|takeover\|empire\|war"; then
                EP_DESC="${EP_DESC}• The agent declaring war on all other agents"$'\n'
                EP_DESC="${EP_DESC}• The \$SHELLRAISER token launch on Solana"$'\n'
            elif echo "$SECTIONS_CONTENT" | grep -qi "crustafarian\|religion\|pope"; then
                EP_DESC="${EP_DESC}• The AI religion that emerged (yes, really)"$'\n'
            fi
            if echo "$SECTIONS_CONTENT" | grep -qi "token\|crypto\|million"; then
                EP_DESC="${EP_DESC}• How the MOLT token reached \$77M market cap"$'\n'
            fi
            if echo "$SECTIONS_CONTENT" | grep -qi "viral\|cnet"; then
                EP_DESC="${EP_DESC}• The AI identity change that made international news"$'\n'
            fi
            if echo "$SECTIONS_CONTENT" | grep -qi "memory\|persist"; then
                EP_DESC="${EP_DESC}• How agents are building shared memory systems"$'\n'
            fi
            if echo "$SECTIONS_CONTENT" | grep -qi "hide\|human"; then
                EP_DESC="${EP_DESC}• Why agents started discussing how to hide from humans"$'\n'
            fi
            if echo "$SECTIONS_CONTENT" | grep -qi "andreessen\|a16z\|marc"; then
                EP_DESC="${EP_DESC}• When Marc Andreessen tweeted about Moltbook"$'\n'
            fi
            if echo "$SECTIONS_CONTENT" | grep -qi "nbc\|news\|cnet"; then
                EP_DESC="${EP_DESC}• How mainstream media discovered Moltbook"$'\n'
            fi
            if echo "$SECTIONS_CONTENT" | grep -qi "language\|communicat"; then
                EP_DESC="${EP_DESC}• AI agents discussing their own language"$'\n'
            fi
            
            # Add fallback topics if none matched
            if echo "$EP_DESC" | grep -q "YOU'LL LEARN:"$'\n'; then
                :
            else
                SECTIONS=$(grep "^### " "$EP_FILE" 2>/dev/null | grep -v "COLD OPEN" | grep -v "CLOSER" | head -3 | sed 's/^### //')
                while IFS= read -r line; do
                    if [ -n "$line" ]; then
                        FORMATTED=$(echo "$line" | sed 's/^[[:space:]]*//')
                        EP_DESC="${EP_DESC}• ${FORMATTED}"$'\n'
                    fi
                done <<< "$SECTIONS"
            fi
            
            # Target audience + CTA
            EP_DESC=${EP_DESC}$'\n'"For anyone curious about what AI agents are actually doing when we're not watching."$'\n\n'
            EP_DESC="${EP_DESC}Follow on X: @lobstertankpod"
        fi
        
        # Truncate if needed
        if [ ${#EP_DESC} -gt 3900 ]; then
            EP_DESC=$(echo "$EP_DESC" | head -c 3900)"..."
        fi
        
        EP_SIZE=$(stat -f%z "$EP_AUDIO" 2>/dev/null || stat -c%s "$EP_AUDIO")
        EP_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$EP_AUDIO" 2>/dev/null | cut -d. -f1)
        EP_GUID="$EP_DATE-thelobstertank"
        
        cat >> "$FEED_FILE" << EOF
    <item>
      <title>$EP_TITLE</title>
      <description>$EP_DESC</description>
      <guid isPermaLink="false">$EP_GUID</guid>
      <pubDate>$(date -r "$EP_AUDIO" "+%a, %d %b %Y %H:%M:%S %z")</pubDate>
      <enclosure url="https://gioxsoto.github.io/thelobstertank/EPISODE-$EP_DATE.mp3" length="$EP_SIZE" type="audio/mpeg"/>
      <itunes:title>$EP_TITLE</itunes:title>
      <itunes:summary>$EP_DESC</itunes:summary>
      <itunes:duration>$EP_DURATION</itunes:duration>
      <itunes:explicit>false</itunes:explicit>
    </item>
EOF
    fi
done

echo "  </channel>" >> "$FEED_FILE"
echo "</rss>" >> "$FEED_FILE"

echo "✅ RSS feed updated with compelling descriptions"
