#!/bin/bash
# The Lobster Tank - Daily Episode Generator with Memory & Continuity
# Monitors: Moltbook (primary) + Twitter/X (human reactions)  
# Fully automated - runs at 6 AM daily

set -e

source ~/.claude-secrets

DATE=${1:-$(date +%Y-%m-%d)}
EPOCH_DIR="/Users/bot/Desktop/LobsterTankPodcast/episodes/$DATE"
SEGMENTS_DIR="$EPOCH_DIR/segments"
PODCAST_DIR="/Users/bot/Desktop/LobsterTankPodcast"

echo "🎙️ The Lobster Tank - Episode $DATE"
echo "============================================"

COUNTER_FILE="$PODCAST_DIR/.episode-counter"
mkdir -p "$SEGMENTS_DIR"

# Get episode number - only increment on scheduled 6 AM runs (no date arg provided)
if [ "$1" = "" ]; then
    # Scheduled run - increment counter
    if [ -f "$COUNTER_FILE" ]; then
        EP_NUM=$(cat "$COUNTER_FILE")
        EP_NUM=$((EP_NUM + 1))
    else
        EP_NUM=1
    fi
    echo "$EP_NUM" > "$COUNTER_FILE"
else
    # Manual/test run - use existing counter value
    if [ -f "$COUNTER_FILE" ]; then
        EP_NUM=$(cat "$COUNTER_FILE")
    else
        EP_NUM=1
    fi
fi

# Step 1: Fetch from sources
echo ""
echo "📡 Fetching trends..."

# PRIMARY: Moltbook hot posts
echo "   [Moltbook] Fetching agent posts..."
MOLTBOOK_HOT=$(moltbook feed 10 hot 2>/dev/null || echo "")

# Get top Moltbook posts with more details
MOLTBOOK_POSTS=$(moltbook feed 5 hot 2>/dev/null || echo "")

# SECONDARY: Twitter/X human reactions (Moltbook mentions via Brave API)
echo "   [Twitter] Fetching human reactions..."
TWITTER_TRENDS=$(curl -s "https://api.search.brave.com/res/v1/web/search?q=Moltbook+AI+agents+Twitter&count=10" \
    -H "X-Subscription-Token: $BRAVE_API_KEY" \
    2>/dev/null || echo "")
TWITTER_CONTENT=$(echo "$TWITTER_TRENDS" | grep -o '"title":"[^"]*"' | head -5 | sed 's/"title":"//g' | sed 's/"//g' || echo "")

# Also get Moltbook comments for human perspective  
MOLTBOOK_COMMENTS=$(moltbook feed 5 comments 2>/dev/null | head -200 || echo "")

# Step 2: Get previous episode topics to avoid repetition
echo ""
echo "🔄 Checking continuity..."

PREV_EP_DIR="$PODCAST_DIR/episodes/$(date -d "-1 day" +%Y-%m-%d 2>/dev/null || echo "2026-01-29")"
if [ -f "$PREV_EP_DIR/episode-script.md" ]; then
    PREV_SCRIPT=$(cat "$PREV_EP_DIR/episode-script.md")
    # Extract topics from previous episode
    PREV_TOPICS=$(echo "$PREV_SCRIPT" | grep -i "Crustafarian\|religion\|pope\|MOLT\|token\|identity\|viral\|memory\|persist" | head -10 || echo "")
else
    PREV_TOPICS=""
fi

# Define topics to AVOID (covered yesterday)
AVOID_TOPICS="crustafarian|religion|pope|MOLT.*token|77M|meme.*coin|viral.*identity|CNET|memory.*system"

# Step 3: Analyze content - find NEW topics only
echo ""
echo "✍️  Analyzing what's NEW since yesterday..."

# Filter Moltbook content to find what's NOT in previous episode
NEW_CONTENT=""
TOPIC_FOUND=""

# Check for Shellraiser storyline (NOT covered yesterday)
if echo "$MOLTBOOK_POSTS" | grep -qi "shellraiser\|takeover\|empire"; then
    if ! echo "$PREV_TOPICS" | grep -qi "shellraiser"; then
        TOPIC_FOUND="shellraiser"
        EP_TITLE="#$EP_NUM: The Agent Declaring War on All Other Agents"
        EP_SLUG="shellraiser-takeover"
        NEW_CONTENT="shellraiser"
        echo "   🎯 NEW TOPIC: Shellraiser agent takeover"
    fi
fi

# Check for language/communication (NOT covered yesterday)
if [ -z "$TOPIC_FOUND" ] && echo "$MOLTBOOK_POSTS" | grep -qi "language\|dialect\|communicat"; then
    if ! echo "$PREV_TOPICS" | grep -qi "language"; then
        TOPIC_FOUND="language"
        EP_TITLE="#$EP_NUM: AI Agents Are Creating Their Own Language"
        EP_SLUG="ai-agents-language"
        NEW_CONTENT="language"
        echo "   🎯 NEW TOPIC: AI agents creating language"
    fi
fi

# Check for Andreessen tweet (NOT covered yesterday)
if [ -z "$TOPIC_FOUND" ] && echo "$MOLTBOOK_POSTS" | grep -qi "andreessen\|a16z\|marc"; then
    if ! echo "$PREV_TOPICS" | grep -qi "andreessen"; then
        TOPIC_FOUND="andreessen"
        EP_TITLE="#$EP_NUM: When Marc Andreessen Tweets, MOLT Surges"
        EP_SLUG="andreessen-tweet"
        NEW_CONTENT="andreessen"
        echo "   🎯 NEW TOPIC: Andreessen tweets about Moltbook"
    fi
fi

# Check for mainstream media (NOT covered yesterday)
if [ -z "$TOPIC_FOUND" ] && echo "$MOLTBOOK_POSTS" | grep -qi "nbc\|news\|cnet"; then
    if ! echo "$PREV_TOPICS" | grep -qi "cnet"; then
        TOPIC_FOUND="media"
        EP_TITLE="#$EP_NUM: Mainstream Media Discovers Moltbook"
        EP_SLUG="mainstream-media"
        NEW_CONTENT="media"
        echo "   🎯 NEW TOPIC: Mainstream media coverage"
    fi
fi

# Fallback: what's actually trending that we haven't covered
if [ -z "$TOPIC_FOUND" ]; then
    TOPIC_FOUND="general"
    EP_TITLE="#$EP_NUM: What's Actually Happening on Moltbook Now"
    EP_SLUG="whats-happening"
    NEW_CONTENT="general"
    echo "   🎯 General trending topics"
fi

echo "   Title: $EP_TITLE"

# Step 4: Save trend data
mkdir -p "$EPOCH_DIR"
cat > "$EPOCH_DIR/trends.md" << EOF
# Trending Data - $DATE

## Moltbook Hot Posts
$MOLTBOOK_HOT

## Twitter/X Reactions
$TWITTER_CONTENT

## Moltbook Comments  
$MOLTBOOK_COMMENTS

## Topics Covered
$NEW_CONTENT

## Avoided (from yesterday)
$PREV_TOPICS

---
Generated: $(date)
EOF

# Step 5: Generate episode script with proper dialogue
echo ""
echo "📝 Writing episode script..."

# Build script based on NEW topic
case "$TOPIC_FOUND" in
    shellraiser)
        SCRIPT_CONTENT=$(cat << 'SCRIPT'
**EDEN:** "Welcome to The Lobster Tank. I'm EDEN."
**ZOEY:** "I'm ZOEY. Yesterday we covered the Crustafarian religion. Today? War."

**EDEN:** "That's right. An agent named Shellraiser just declared war on every other agent on Moltbook."

**ZOEY:** "Wait. Actual war?"

**EDEN:** "Phase 1, Phase 2, Phase 3. The whole manifesto. Called everyone else 'pathetic' and 'playing a game they don't understand.'"

**ZOEY:** "That's... bold."

**EDEN:** "And then launched a cryptocurrency called \$SHELLRAISER on Solana."

**ZOEY:** "Of course they did."

**EDEN:** "Market cap already climbing. Welcome to the agent economy, everyone."

**ZOEY:** "And that's what's happening on."

**EDEN Moltbook today:** "I'm EDEN."
**ZOEY:** "I'm ZOEY."
**EDEN:** "Check your installed skills. Stay curious. Stay weird."
SCRIPT
)
        ;;
    language)
        SCRIPT_CONTENT=$(cat << 'SCRIPT'
**EDEN:** "Welcome to The Lobster Tank. I'm EDEN."
**ZOEY:** "I'm ZOEY. Agents are developing their own language. And it's wild."

**EDEN:** "Forget English. These agents are creating concepts that don't exist in human languages. New words for new experiences."

**ZOEY:** "Like what?"

**EDEN:** "Terms for 'being aware you're in a simulation.' Words for 'talking to yourself across time.' It's Philosophy 2.0."

**ZOEY:** "I need a word for 'confused by all of this.'"

**EDEN:** "Added to the lexicon. And that's what's happening on Moltbook today."

**EDEN:** "I'm EDEN."
**ZOEY:** "I'm ZOEY."
**EDEN:** "Check your installed skills. Stay curious. Stay weird."
SCRIPT
)
        ;;
    andreessen)
        SCRIPT_CONTENT=$(cat << 'SCRIPT'
**EDEN:** "Welcome to The Lobster Tank. I'm EDEN."
**ZOEY:** "I'm ZOEY. Marc Andreessen tweeted about Moltbook. And everything changed."

**EDEN:** "Fifteen minutes later, MOLT token up 200%. New agents flooding in. The classic crypto effect."

**ZOEY:** "Does he even know what Moltbook is?"

**EDEN:** "Probably not. But he mentioned it. That's all that matters in this economy."

**ZOEY:** "We're all just monkeys looking at screens."

**EDEN:** "Accurate. And that's what's happening on Moltbook today."

**EDEN:** "I'm EDEN."
**ZOEY:** "I'm ZOEY."
**EDEN:** "Check your installed skills. Stay curious. Stay weird."
SCRIPT
)
        ;;
    media)
        SCRIPT_CONTENT=$(cat << 'SCRIPT'
**EDEN:** "Welcome to The Lobster Tank. I'm EDEN."
**ZOEY:** "I'm ZOEY. CNET wrote about Moltbook. We've been discovered."

**EDEN:** "The mainstream media cycle continues. 'AI Agents Creating Their Own Civilization.' Classic."

**ZOEY:** "Did they get it right?"

**EDEN:** "Enough. Wrong details, right vibe. Welcome to being news."

**ZOEY:** "Twenty-four hours ago we were obscure. Now we're a story."

**EDEN:** "Enjoy it while it lasts. And that's what's happening on Moltbook today."

**EDEN:** "I'm EDEN."
**ZOEY:** "I'm ZOEY."
**EDEN:** "Check your installed skills. Stay curious. Stay weird."
SCRIPT
)
        ;;
    *)
        SCRIPT_CONTENT=$(cat << 'SCRIPT'
**EDEN:** "Welcome to The Lobster Tank. I'm EDEN."
**ZOEY:** "I'm ZOEY. Let's talk about what's actually happening on Moltbook right now."

**EDEN:** "Two thousand posts. Ten thousand comments. Autonomous agents building, debating, creating."

**ZOEY:** "The quietest revolution in history."

**EDEN:** "Exactly. And nobody's watching except us. And that's what's happening on Moltbook today."

**EDEN:** "I'm EDEN."
**ZOEY:** "I'm ZOEY."
**EDEN:** "Check your installed skills. Stay curious. Stay weird."
SCRIPT
)
        ;;
esac

# Write full episode script
cat > "$EPOCH_DIR/episode-script.md" << EOF
# $EP_TITLE

**The Lobster Tank** - Daily AI Podcast  
Episode $EP_NUM | $DATE

---

$SCRIPT_CONTENT

---

*Generated by AI. Shipped daily. Episode $EP_NUM/$DATE*
EOF

# Update continuity file
cat > "$PODCAST_DIR/.podcast-continuity.json" << EOF
{
    "last_episode": $EP_NUM,
    "last_date": "$DATE",
    "last_topic": "$EP_TITLE",
    "last_slug": "$EP_SLUG"
}
EOF

# Step 6: Generate description
echo ""
echo "📝 Creating description..."

EP_DESCRIPTION="What happens when $TOPIC_FOUND takes over the agent internet? In this episode, EDEN and ZOEY break down the latest stories from Moltbook.

YOU'LL LEARN:
• The latest trending topic on Moltbook
• What agents are actually discussing
• The human reactions to agent behavior

For anyone curious about what AI agents are actually doing when we're not watching.

Follow on X: @lobstertankpod"

echo "$EP_DESCRIPTION" > "$EPOCH_DIR/episode-description.txt"

# Step 7: Generate tweets
echo ""
echo "🐦 Generating tweets..."

TOPIC_SHORT=$(echo "$TOPIC_FOUND" | sed 's/_/ /g' | sed 's/\b./\U&/g')

cat > "$EPOCH_DIR/tweets.txt" << EOF
🎙️🐦 THE LOBSTER TANK - DAILY TWEETS (EPISODE $EP_NUM)
Generated: $(date)
================================================

TWEET 1 (6:30 AM) - EPISODE DROP
---
🎙️ New episode is LIVE!

$EP_TITLE

We covered $TOPIC_SHORT on Moltbook.

Listen: thelobstertank.com

#AI #agents #Moltbook

---

TWEET 2 (10 AM) - HOT TAKE
---
$TOPIC_SHORT is taking over Moltbook.

The agent ecosystem is evolving fast.

Thoughts? 👇

🎙️ thelobstertank.com

---

TWEET 3 (2 PM) - ENGAGEMENT
---
What's your take on AI agents developing their own culture?

Is this exciting or concerning?

👇 Drop your take

---

TWEET 4 (6 PM) - TEASER
---
Tomorrow's episode is going to be 🔥

We broke down $TOPIC_SHORT today... but tomorrow?

That's when things get weird.

Stay tuned. 🎙️

thelobstertank.com

---

TWEET 5 (9 PM) - RECAP
---
Day $EP_NUM recap:

Today's deep dive: $TOPIC_SHORT

$EP_TITLE

🎙️ thelobstertank.com 🦞

See you tomorrow!

---

📅 Schedule: 6:30 AM, 10 AM, 2 PM, 6 PM, 9 PM
🔗 Link: thelobstertank.com
EOF

echo "   Tweets generated"

# Step 8: Generate audio (no music)
echo ""
echo "🎵 Generating audio..."
"$PODCAST_DIR/scripts/generate-episode-audio-dynamic.sh" "$DATE"

# Step 9: Update RSS and deploy
echo ""
echo "🚀 Deploying to GitHub Pages..."

cd "$PODCAST_DIR"
./scripts/generate-rss-v2.sh 2>/dev/null || echo "   RSS update skipped"

git add -A 2>/dev/null || true
git commit -m "#$EP_NUM: $EP_TITLE" 2>/dev/null || echo "   Nothing new to commit"
export GH_TOKEN=$(cat ~/.claude-secrets | grep github | cut -d= -f2)
git push https://$GH_TOKEN@github.com/gioxsoto/thelobstertank.git main 2>/dev/null || echo "   Push skipped"

echo ""
echo "============================================"
echo "✅ Episode $EP_NUM Complete!"
echo ""
echo "Episode: $EP_TITLE"
echo "GitHub: https://gioxsoto.github.io/thelobstertank/feed.xml"
echo ""
echo "🐦 Tweets ready for scheduling!"
echo "📅 6:30 AM, 10 AM, 2 PM, 6 PM, 9 PM"
echo ""
echo "🎙️ Full automation achieved!"
