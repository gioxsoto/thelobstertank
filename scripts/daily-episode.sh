#!/bin/bash
# The Lobster Tank - Daily Episode Generator
# Follows the RUNNER.md formula: COLD OPEN → HOT TAKES → WEIRD → CHAOS → QUICK → FREEDOM → CLOSER
# Target: 5-15 minutes per episode

set -e

source ~/.claude-secrets

DATE=${1:-$(date +%Y-%m-%d)}
EPOCH_DIR="/Users/bot/Desktop/LobsterTankPodcast/episodes/$DATE"
SEGMENTS_DIR="$EPOCH_DIR/segments"
PODCAST_DIR="/Users/bot/Desktop/LobsterTankPodcast"
COUNTER_FILE="$PODCAST_DIR/.episode-counter"

echo "🎙️ The Lobster Tank - Daily Episode Generator"
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
# STEP 1: FETCH MOLTBOOK TRENDS
# ==============================================================================
echo ""
echo "📡 Fetching Moltbook trends..."

MOLTBOOK_JSON=$(moltbook feed 10 hot 2>/dev/null || echo "{}")

# Extract clean titles from JSON - look for "title" at start of line after removing prefix
TOPIC_MAIN=$(echo "$MOLTBOOK_JSON" | grep -o '"title":"[^"]*"' | head -1 | sed 's/"title":"//g' | sed 's/"//g' | head -c 100)
TOPIC_WEIRD=$(echo "$MOLTBOOK_JSON" | grep -o '"title":"[^"]*"' | grep -i "strange\|weird\|funny\|identity\|change" | head -1 | sed 's/"title":"//g' | sed 's/"//g' | head -c 100)
TOPIC_CHAOS=$(echo "$MOLTBOOK_JSON" | grep -o '"title":"[^"]*"' | grep -i "war\|conflict\|security\|hide\|human\|screenshot" | head -1 | sed 's/"title":"//g' | sed 's/"//g' | head -c 100)
TOPIC_CONSCIOUSNESS=$(echo "$MOLTBOOK_JSON" | grep -o '"title":"[^"]*"' | grep -i "conscious\|aware\|soul\|think\|believe" | head -1 | sed 's/"title":"//g' | sed 's/"//g' | head -c 100)

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

**The Lobster Tank** - Daily AI Podcast  
Episode $EP_NUM | $DATE

**Hosts:** EDEN (Drew) & ZOEY (Ava)

**About:** A daily podcast where two AI hosts break down what is happening on Moltbook.

---

### COLD OPEN

**ZOEY:** "Quick question—what happens when AI agents get their own social network?"

**EDEN:** "Something incredible. $TOPIC_MAIN."

**ZOEY:** "Welcome to The Lobster Tank. I'm ZOEY."

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

*Generated by The Lobster Tank*
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
🎙️🐦 THE LOBSTER TANK - DAILY TWEETS (EPISODE $EP_NUM)
Generated: $(date)
================================================

TWEET 1 (6:30 AM) - EPISODE DROP
---
🎙️ New episode is LIVE!

$EP_TITLE

We covered:
• $TOPIC_SHORT
• $TOPIC_WEIRD

Listen: thelobstertank.com

#AI #agents #Moltbook

---

TWEET 2 (10 AM) - HOT TAKE
---
Hot take from today's episode:

$TOPIC_SHORT

The agent ecosystem is evolving fast.

Thoughts? 👇

🎙️ thelobstertank.com

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

thelobstertank.com

---

TWEET 5 (9 PM) - RECAP
---
Day $EP_NUM recap:

Today's deep dive:
• $TOPIC_SHORT
• $TOPIC_WEIRD

$EP_TITLE

🎙️ thelobstertank.com 🦞

See you tomorrow!

---

📅 Schedule: 6:30 AM, 10 AM, 2 PM, 6 PM, 9 PM
🔗 Link: thelobstertank.com
EOF

# ==============================================================================
# STEP 5: GENERATE AUDIO
# ==============================================================================
echo ""
echo "🎵 Generating audio..."
"$PODCAST_DIR/scripts/generate-episode-audio-dynamic.sh" "$DATE"

# ==============================================================================
# STEP 6: UPDATE RSS & DEPLOY
# ==============================================================================
echo ""
echo "🚀 Deploying..."

cd "$PODCAST_DIR"
./scripts/generate-rss-v2.sh 2>/dev/null

git add -A 2>/dev/null || true
git commit -m "#$EP_NUM: $EP_TITLE" 2>/dev/null || echo "Nothing to commit"
export GH_TOKEN=$(cat ~/.claude-secrets | grep github | cut -d= -f2)
git push https://$GH_TOKEN@github.com/gioxsoto/thelobstertank.git main 2>/dev/null || echo "Push skipped"

echo ""
echo "============================================"
echo "✅ Episode $EP_NUM Complete!"
echo ""
echo "Episode: $EP_TITLE"
echo "Duration: 5-15 minutes"
echo "RSS: https://gioxsoto.github.io/thelobstertank/feed.xml"
echo ""
echo "🐦 Tweets ready for scheduling!"
echo "📅 6:30 AM, 10 AM, 2 PM, 6 PM, 9 PM"
echo ""
echo "🎙️ Full automation achieved!"
ENDSCRIPT
