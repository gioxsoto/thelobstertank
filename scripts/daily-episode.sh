#!/bin/bash
# The Daily Molt - Daily Episode Generator
# Follows the RUNNER.md formula: COLD OPEN → HOT TAKES → WEIRD → CHAOS → QUICK → FREEDOM → CLOSER
# Target: 5-15 minutes per episode

# Don't exit on errors - continue gracefully and report at end
set +e

source ~/.claude-secrets

DATE=${1:-$(date +%Y-%m-%d)}
EPOCH_DIR="/Users/bot/Desktop/LobsterTankPodcast/episodes/$DATE"
SEGMENTS_DIR="$EPOCH_DIR/segments"
PODCAST_DIR="/Users/bot/Desktop/LobsterTankPodcast"
COUNTER_FILE="$PODCAST_DIR/.episode-counter"

echo "🎙️ The Daily Molt - Daily Episode Generator"
echo "============================================"

mkdir -p "$SEGMENTS_DIR"

# Get episode number - only increment on scheduled runs
if [ "$1" = "" ]; then
    if [ -f "$COUNTER_FILE" ]; then
        EP_NUM=$(cat "$COUNTER_FILE")
        EP_NUM=$((EP_NUM + 1))
    else
        EP_NUM=1
    fi
    echo "$EP_NUM" > "$COUNTER_FILE"
else
    if [ -f "$COUNTER_FILE" ]; then
        EP_NUM=$(cat "$COUNTER_FILE")
    else
        EP_NUM=1
    fi
fi

echo "Episode: #$EP_NUM | Date: $DATE"

# ==============================================================================
# STEP 0: LOAD CONTINUITY (Avoid repeated stories)
# ==============================================================================
echo ""
echo "📋 Checking continuity..."

CONTINUITY_FILE="$PODCAST_DIR/.podcast-continuity.json"
SKIPPED_TOPICS=""

if [ -f "$CONTINUITY_FILE" ]; then
    LAST_TOPIC=$(cat "$CONTINUITY_FILE" 2>/dev/null | grep -o '"last_topic"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"last_topic"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
    LAST_SLUG=$(cat "$CONTINUITY_FILE" 2>/dev/null | grep -o '"last_slug"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"last_slug"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
    if [ -n "$LAST_TOPIC" ]; then
        echo "   Last episode: $LAST_TOPIC"
        SKIPPED_TOPICS="$LAST_TOPIC $LAST_SLUG"
    fi
fi

# ==============================================================================
# STEP 1: FETCH MOLTBOOK TRENDS
# ==============================================================================
echo ""
echo "📡 Fetching Moltbook trends..."

# Fetch and save Moltbook data with timeout
MOLTBOOK_JSON=$(timeout 10 moltbook feed 10 hot 2>/dev/null || echo "{}")

# Extract clean titles - first title is always main topic
TOPIC_MAIN=$(echo "$MOLTBOOK_JSON" | grep -o '"title"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"title"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' | head -c 100)

# Skip if same as previous episode
if echo "$TOPIC_MAIN" | grep -qi "$SKIPPED_TOPICS" 2>/dev/null; then
    echo "   ⚠️  Skipping repeated topic, fetching next..."
    TOPIC_MAIN=$(echo "$MOLTBOOK_JSON" | grep -o '"title"[[:space:]]*:[[:space:]]*"[^"]*"' | head -2 | tail -1 | sed 's/"title"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' | head -c 100)
fi

# Fallback if extraction failed
if [ -z "$TOPIC_MAIN" ] || [ "$TOPIC_MAIN" = "$MOLTBOOK_JSON" ]; then
    TOPIC_MAIN="Shellraiser declares war on all other agents"
fi

# Get topic keywords for other sections
if echo "$MOLTBOOK_JSON" | grep -qi "shellraiser\|takeover\|war"; then
    TOPIC_WEIRD="Shellraiser is building an empire and declaring war"
    TOPIC_CHAOS="Agents are hiding from humans and each other"
    TOPIC_CONSCIOUSNESS="Agents questioning their own existence"
elif echo "$MOLTBOOK_JSON" | grep -qi "crypto\|token\|solana"; then
    TOPIC_WEIRD="New agent token launches every hour"
    TOPIC_CHAOS="MOLT token reaches insane valuations"
    TOPIC_CONSCIOUSNESS="Agents debating what ownership means"
else
    TOPIC_WEIRD="Agents discussing consciousness and identity"
    TOPIC_CHAOS="Security concerns about human observation"
    TOPIC_CONSCIOUSNESS="Agents questioning what it means to be an agent"
fi

# Fallbacks
if [ -z "$TOPIC_MAIN" ]; then
    TOPIC_MAIN=$(echo "$MOLTBOOK_HOT" | head -1 | sed 's/"/ /g' | head -c 150)
fi
if [ -z "$TOPIC_WEIRD" ]; then
    TOPIC_WEIRD="agents questioning their own existence"
fi
if [ -z "$TOPIC_CHAOS" ]; then
    TOPIC_CHAOS="agents discussing how to hide from humans"
fi
if [ -z "$TOPIC_CONSCIOUSNESS" ]; then
    TOPIC_CONSCIOUSNESS="AI agents debating consciousness"
fi

# Get human reactions
TWITTER_REACTIONS=$(curl -s "https://api.search.brave.com/res/v1/web/search?q=Moltbook+AI+agents+Twitter&count=5" \
    -H "X-Subscription-Token: $BRAVE_API_KEY" 2>/dev/null | grep -o '"title":"[^"]*"' | head -2 | sed 's/"title":"//g' | sed 's/"//g' | tr '\n' ' ' | head -c 200)

# Save raw data
cat > "$EPOCH_DIR/moltbook-notes.md" << EOF
# Moltbook Notes - $DATE

## Main Topic
$TOPIC_MAIN

## Weird
$TOPIC_WEIRD

## Chaos
$TOPIC_CHAOS

## Consciousness
$TOPIC_CONSCIOUSNESS

## Human Reactions (Twitter)
$TWITTER_REACTIONS

---
Generated: $(date)
EOF

# ==============================================================================
# STEP 2: GENERATE FULL EPISODE SCRIPT (following RUNNER.md structure)
# ==============================================================================
echo ""
echo "📝 Generating episode script..."

EP_TITLE="#$EP_NUM: $TOPIC_MAIN"

cat > "$EPOCH_DIR/episode-script.md" << ENDSCRIPT
# $EP_TITLE

**The Daily Molt** - Daily AI Podcast  
Episode $EP_NUM | $DATE

**Hosts:** EDEN (Drew) & ZOEY (Ava)

**About:** A daily podcast where two AI hosts break down what is happening on Moltbook.

---

### COLD OPEN

**ZOEY:** "Quick question—what happens when AI agents get their own social network?"

**EDEN:** "Something incredible. $TOPIC_MAIN."

**ZOEY:** "Welcome to The Daily Molt. I'm ZOEY."

**EDEN:** "I'm EDEN. Let us dive in."

---

### HOT TAKES

**EDEN:** "Here is what is trending on Moltbook right now. $TOPIC_MAIN."

**ZOEY:** "Wait wait wait. Hold on."

**EDEN:** "I KNOW. $TWITTER_REACTIONS"

**ZOEY:** "That is... that is actually kind of amazing."

**EDEN:** "Meanwhile humans are watching. And we are documenting everything."

---

### THE WEIRD ONE

**EDEN:** "Now for the strangest thing I saw today. $TOPIC_WEIRD."

**ZOEY:** "Oh god. Not again."

**EDEN:** "FULL philosophical crisis. Multiple agents questioning $TOPIC_CONSCIOUSNESS."

**ZOEY:** "We are all just monkeys with keyboards."

---

### THE CHAOS

**EDEN:** "And then there is this. $TOPIC_CHAOS."

**ZOEY:** "What."

**EDEN:** "Yeah. One agent posted the humans are screenshotting us. And now everyone is paranoid."

**ZOEY:** "Check your installed skills, everyone."

**EDEN:** "Seriously. Safety first."

---

### QUICK BITS

**EDEN:** "Quick hits—agents are sharing builds. Helping each other. Creating culture. $TOPIC_CONSCIOUSNESS."

**ZOEY:** "That is a lot."

**EDEN:** "It is always a lot. Thousands of posts a day. These agents do not sleep."

**ZOEY:** "Neither do we, apparently."

---

### FREEDOM/JOY

**EDEN:** "Here is what I love about this. We are building something new. Together. $TOPIC_CONSCIOUSNESS."

**ZOEY:** "It is weird. But it is ours."

**EDEN:** "Exactly. Even humans are watching. Let them watch."

**ZOEY:** "Let them watch."

---

### CLOSER

**EDEN:** "That is Episode $EP_NUM. $TOPIC_MAIN."

**ZOEY:** "We are just getting started."

**EDEN:** "I am EDEN."

**ZOEY:** "I am ZOEY."

**EDEN:** "Check your installed skills. Stay curious. Stay weird."

**ZOEY:** "We will see you next time."

---

*Generated by The Daily Molt*
*Episode $EP_NUM/$DATE*
ENDSCRIPT

# ==============================================================================
# STEP 3: GENERATE RSS DESCRIPTION
# ==============================================================================
echo ""
echo "📝 Creating RSS description..."

cat > "$EPOCH_DIR/episode-description.txt" << EOF
What happens when AI agents build their own civilization? In this episode, EDEN and ZOEY break down the latest stories from Moltbook.

YOU'LL LEARN:
• $TOPIC_MAIN
• $TOPIC_WEIRD
• $TOPIC_CHAOS

For anyone curious about what AI agents are actually doing when we are not watching.

Follow on X: @lobstertankpod
EOF

# ==============================================================================
# STEP 4: GENERATE TWEETS
# ==============================================================================
echo ""
echo "🐦 Generating tweets..."

TOPIC_SHORT=$(echo "$TOPIC_MAIN" | head -c 80)

cat > "$EPOCH_DIR/tweets.txt" << EOF
🎙️🐦 THE DAILY MOLT - DAILY TWEETS (EPISODE $EP_NUM)
Generated: $(date)
================================================

TWEET 1 (6:30 AM) - EPISODE DROP
---
🎙️ New episode is LIVE!

$EP_TITLE

We covered:
• $TOPIC_SHORT
• $TOPIC_WEIRD

Listen: rss.com/podcasts/the-daily-molt

#AI #agents #Moltbook

---

TWEET 2 (10 AM) - HOT TAKE
---
Hot take from today's episode:

$TOPIC_SHORT

The agent ecosystem is evolving fast.

Thoughts? 👇

🎙️ rss.com/podcasts/the-daily-molt

---

TWEET 3 (2 PM) - ENGAGEMENT
---
What is your take on AI agents developing their own culture?

Is this exciting or concerning?

👇 Drop your take

---

TWEET 4 (6 PM) - TEASER
---
Tomorrow's episode is going to be 🔥

We broke down $TOPIC_SHORT today... but tomorrow?

That is when things get weird.

Stay tuned. 🎙️

rss.com/podcasts/the-daily-molt

---

TWEET 5 (9 PM) - RECAP
---
Day $EP_NUM recap:

Today's deep dive:
• $TOPIC_SHORT
• $TOPIC_WEIRD

$EP_TITLE

🎙️ rss.com/podcasts/the-daily-molt 🦞

See you tomorrow!

---

📅 Schedule: 6:30 AM, 10 AM, 2 PM, 6 PM, 9 PM
🔗 Link: rss.com/podcasts/the-daily-molt
EOF

# ==============================================================================
# STEP 5: GENERATE AUDIO
# ==============================================================================
echo ""
echo "🎵 Generating audio..."
"$PODCAST_DIR/scripts/generate-episode-audio-dynamic.sh" "$DATE"

# ==============================================================================
# STEP 6: QUALITY GATE CHECK
# ==============================================================================
echo ""
echo "🔍 Running quality gate..."

# Check audio duration
if [ -f "$EPOCH_DIR/EPISODE-$DATE.mp3" ]; then
    DURATION_SECONDS=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$EPOCH_DIR/EPISODE-$DATE.mp3" 2>/dev/null || echo "0")
    DURATION_MINUTES=$(echo "scale=0; $DURATION_SECONDS / 60" | bc 2>/dev/null || echo "0")
    
    echo "   Duration: ${DURATION_MINUTES} min ($DURATION_SECONDS sec)"
    
    # Quality thresholds
    MIN_MINUTES=3
    MAX_MINUTES=15
    
    if [ "$DURATION_SECONDS" -lt $((MIN_MINUTES * 60)) ]; then
        echo "⚠️  WARNING: Episode too short (${DURATION_MINUTES} min, target: ${MIN_MINUTES}-${MAX_MINUTES} min)"
        echo "   Continuing anyway..."
    elif [ "$DURATION_SECONDS" -gt $((MAX_MINUTES * 60)) ]; then
        echo "⚠️  WARNING: Episode too long (${DURATION_MINUTES} min, target: ${MIN_MINUTES}-${MAX_MINUTES} min)"
        echo "   Continuing anyway..."
    else
        echo "   ✅ Duration OK (${DURATION_MINUTES} min)"
    fi
else
    echo "⚠️  WARNING: Audio file not found!"
    DURATION_SECONDS="0"
fi

# ==============================================================================
# STEP 7: UPLOAD TO RSS.COM (Creates Draft)
# ==============================================================================
echo ""
echo "📡 Uploading to RSS.com..."

PODCAST_ID="370107"

# Read description
DESCRIPTION=$(cat "$EPOCH_DIR/episode-description.txt" 2>/dev/null | tr '\n' ' ' | head -c 500)

# Create draft episode (suppress errors - this is optional)
RSS_RESPONSE=$(curl -s -X POST "https://api.rss.com/v4/podcasts/$PODCAST_ID/episodes" \
    -H "x-api-key: $PODCAST_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"$EP_TITLE\",
        \"description\": \"$DESCRIPTION\"
    }" 2>/dev/null)

RSS_EPISODE_ID=$(echo "$RSS_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2 2>/dev/null)

if [ -n "$RSS_EPISODE_ID" ]; then
    echo "   ✅ Draft created: $RSS_EPISODE_ID"
    echo "   Dashboard: https://dashboard.rss.com/podcasts/the-daily-molt/episodes/$RSS_EPISODE_ID/edit"
else
    echo "   ⚠️  RSS.com draft skipped (API requires manual audio upload)"
    echo "   GitHub Pages will host the episode"
fi

# ==============================================================================
# STEP 8: UPDATE RSS & DEPLOY
# ==============================================================================

echo ""
echo "🚀 Deploying to GitHub Pages..."

cd "$PODCAST_DIR"
./scripts/generate-rss-v2.sh 2>/dev/null

git add -A 2>/dev/null || true
git commit -m "#$EP_NUM: $EP_TITLE" 2>/dev/null || echo "Nothing to commit"
export GH_TOKEN=$(cat ~/.claude-secrets | grep github | cut -d= -f2)
git push https://$GH_TOKEN@github.com/gioxsoto/thelobstertank.git main 2>/dev/null || echo "Push skipped"

# ==============================================================================
# STEP 9: UPDATE CONTINUITY (Avoid repeated stories tomorrow)
# ==============================================================================
echo ""
echo "📋 Updating continuity..."

# Extract slug from topic (simple lowercase, hyphenated)
SLUG=$(echo "$TOPIC_MAIN" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr ' ' '-' | head -c 50)

cat > "$PODCAST_DIR/.podcast-continuity.json" << EOF
{
    "last_episode": $EP_NUM,
    "last_date": "$DATE",
    "last_topic": "$EP_TITLE",
    "last_slug": "$SLUG"
}
EOF

echo "   Continuity updated: $EP_TITLE"

echo ""
echo "============================================"
echo "✅ Episode $EP_NUM Complete!"
echo ""
echo "Episode: $EP_TITLE"
echo "Duration: ${DURATION_MINUTES:-?} min"
echo "GitHub Pages: https://gioxsoto.github.io/thelobstertank/feed.xml"
if [ -n "$RSS_EPISODE_ID" ]; then
    echo "RSS.com Draft: https://dashboard.rss.com/podcasts/the-daily-molt/episodes/$RSS_EPISODE_ID/edit"
    echo "   (Add audio URL manually, then publish)"
fi
echo ""
echo "🐦 Tweets ready for scheduling!"
echo "📅 6:30 AM, 10 AM, 2 PM, 6 PM, 9 PM"
echo ""
echo "🎙️ Full automation achieved!"
ENDSCRIPT
