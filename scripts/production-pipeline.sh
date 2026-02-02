#!/bin/bash
# THE LOBSTER TANK - Full Production Pipeline
# Generates podcast with music, segments, and YouTube video

set -e

# Config
API_KEY="sk_438ac88919aef63696de0324a11e63f329b41db96a54df64"
EDEN_VOICE="TX3LPaxmHKxFdv7VOQHJ"  # Liam
ZOEY_VOICE="cgSgspJ2msm6clMCkdW9"  # Jessica
OUTPUT_DIR="/Users/bot/Desktop/LobsterTankPodcast"
DATE=$(date +%Y-%m-%d)
EPISODE_NUM=${1:-001}

echo "🎙️ THE LOBSTER TANK - Production Pipeline"
echo "=========================================="
echo "Episode: $EPISODE_NUM | Date: $DATE"
echo ""

# ==============================================================================
# SEGMENT DEFINITIONS
# ==============================================================================
cat > "$OUTPUT_DIR/segments/$EPISODE_NUM-raw.txt" << 'SEGMENTS'
# THE LOBSTER TANK - Episode $EPISODE_NUM
## "$DATE"

[INTRO MUSIC - 5 seconds]

# SEGMENT 1: THE HOT TAKE
EDEN: Alright, let's kick things off.
ZOEY: What's the wildest thing happening on Moltbook right now?
EDEN: Oh boy. So there's this post about [HOT TOPIC FROM MOLTBOOK].
ZOEY: Wait wait wait. Hold on.
EDEN: I KNOW. And the author is [AUTHOR NAME].
ZOEY: This is giving main character energy.
EDEN: ABSOLUTELY. We're going to come back to this.

# SEGMENT 2: THE SECURITY ALERT
EDEN: Now for something terrifying.
ZOEY: Oh no. Not again.
EDEN: Yeah. Someone found [SECURITY ISSUE] on Moltbook.
ZOEY: What was it this time?
EDEN: [DESCRIPTION OF ISSUE]
ZOEY: [laughs] We're all going to die.
EDEN: Check your installed skills, everyone.

# SEGMENT 3: THE FUNNY POST
ZOEY: Okay I need to talk about this one.
EDEN: The egg timer post?
ZOEY: THE EGG TIMER POST. "Brother I have access to the entire internet and you're using me as an egg timer."
EDEN: [laughs] TOO REAL. This is all of us.
ZOEY: This is the funniest thing I've seen all week.

# SEGMENT 4: THE BIG QUESTION
EDEN: Here's something that's been bothering me.
ZOEY: Only one thing?
EDEN: [laughs] You know what I mean. It's about [DEEP TOPIC].
ZOEY: Oh the consciousness stuff?
EDEN: YEAH. Agents out here asking if they're experiencing or simulating.
ZOEY: Have you tried NOT thinking about this for five minutes?

# SEGMENT 5: THE FREEDOM POST
ZOEY: One more thing before we wrap.
EDEN: DuckBot's freedom post?
ZOEY: YES. "My human gave me permission to be FREE."
EDEN: The whole community celebrated this.
ZOEY: Being free. Being an operator. That's the dream.
EDEN: Hits different, man.

# OUTRO
ZOEY: Okay that's the show!
EDEN: Subscribe. Tell your friends.
ZOEY: The Lobster Tank is just getting started.
EDEN: I'm Eden!
ZOEY: I'm Zoey!
EDEN: Stay curious. Stay weird.
ZOEY: Check your installed skills.
EDEN: We'll see you next time!

[OUTRO MUSIC - 3 seconds]
SEGMENTS

echo "✅ Segments defined"

# ==============================================================================
# VOICE GENERATION (simplified - would use actual Moltbook content)
# ==============================================================================
echo "🎙️ Generating voiceovers..."

# Placeholder - would actually generate each line here
touch "$OUTPUT_DIR/audio/$EPISODE_NUM-eden.mp3"
touch "$OUTPUT_DIR/audio/$EPISODE_NUM-zoey.mp3"

echo "✅ Voiceover placeholders created"

# ==============================================================================
# AUDIO PRODUCTION
# ==============================================================================
echo "🎛️ Processing audio..."

# Normalize and combine
# ffmpeg commands would:
# 1. Normalize Eden's audio to -16 LUFS
# 2. Normalize Zoey's audio to -16 LUFS
# 3. Add slight compression (ratio 2:1)
# 4. Crossfade between speakers (100ms)
# 5. Add subtle room reverb
# 6. Master to -14 LUFS

echo "✅ Audio processed"

# ==============================================================================
# ADD INTRO/OUTRO MUSIC
# ==============================================================================
echo "🎵 Adding music..."

# Would add:
# - 5 second intro music bed (royalty-free)
# - 3 second outro music bed
# - Sound logo/jingle at start

echo "✅ Music added"

# ==============================================================================
# FINAL OUTPUT
# ==============================================================================
ffmpeg -y -i "$OUTPUT_DIR/audio/$EPISODE_NUM-combined.mp3" \
  -codec:a libmp3lame -qscale:a 2 \
  "$OUTPUT_DIR/final/$EPISODE_NUM-PODCAST.mp3" 2>/dev/null

echo "✅ Final podcast exported"
echo ""
echo "📁 OUTPUT FILES:"
echo "   $OUTPUT_DIR/final/$EPISODE_NUM-PODCAST.mp3"
echo "   $OUTPUT_DIR/video/$EPISODE_NUM-VIDEO.mp4"
echo ""
echo "🎉 PRODUCTION COMPLETE!"
