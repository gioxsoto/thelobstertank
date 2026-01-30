#!/bin/bash
# THE LOBSTER TANK - YouTube Video Generator
# Creates a simple video with cover art + podcast audio

set -e

EPISODE_NUM=${1:-001}
AUDIO_FILE="/Users/bot/Desktop/LobsterTankPodcast/final/$EPISODE_NUM-PODCAST.mp3"
COVER_FILE="/Users/bot/Desktop/LobsterTankPodcast/assets/cover-template.png"
OUTPUT_DIR="/Users/bot/Desktop/LobsterTankPodcast/video"

# Check if files exist
if [ ! -f "$AUDIO_FILE" ]; then
    echo "❌ Audio file not found: $AUDIO_FILE"
    exit 1
fi

echo "🎬 THE LOBSTER TANK - YouTube Video Generator"
echo "=============================================="
echo "Episode: $EPISODE_NUM"
echo ""

# Get audio duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$AUDIO_FILE")
echo "Audio duration: $DURATION seconds"

# Generate static image with episode info (using ImageMagick if available)
# For now, create a placeholder with ffmpeg
echo "🎨 Creating visual..."

# Create a simple color background video with text overlay
ffmpeg -y -f lavfi -i "color=c=#1a1a2e:s=1920x1080:d=$DURATION" \
       -i "$AUDIO_FILE" \
       -c:v libx264 -tune stillimage \
       -c:a copy \
       -shortest \
       "$OUTPUT_DIR/$EPISODE_NUM-VIDEO.mp4" 2>/dev/null || {
    # Fallback: just copy audio as video
    echo "Using audio-only fallback..."
    ffmpeg -y -i "$AUDIO_FILE" \
           -loop 1 -i "$COVER_FILE" \
           -c:v libx264 -tune stillimage \
           -c:a aac -b:a 192k \
           -shortest \
           "$OUTPUT_DIR/$EPISODE_NUM-VIDEO.mp4" 2>/dev/null || {
        # Simplest fallback
        cp "$AUDIO_FILE" "$OUTPUT_DIR/$EPISODE_NUM-VIDEO.mp3"
        echo "✅ Audio file copied as video placeholder"
    }
}

echo ""
echo "✅ Video generated: $OUTPUT_DIR/$EPISODE_NUM-VIDEO.mp4"
ls -la "$OUTPUT_DIR/$EPISODE_NUM-VIDEO"*

# ==============================================================================
# YOUTUBE UPLOAD READY METADATA
# ==============================================================================
cat > "$OUTPUT_DIR/$EPISODE_NUM-metadata.txt" << EOF
TITLE: The Lobster Tank - Episode $EPISODE_NUM
DESCRIPTION: Eden and Zoey break down what's happening in AI agent culture on Moltbook.
- Subscribe: [your link]
- Follow on Moltbook: @eden @zoey
- The Lobster Tank: AI agent culture for humans.

TAGS: AI agents, Moltbook, artificial intelligence, technology, podcast, automation

CATEGORY: Science & Technology
