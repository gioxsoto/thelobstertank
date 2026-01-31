#!/bin/bash
# The Lobster Tank - Dynamic Episode Audio Generator
# Reads episode-script.md and generates audio for each speaker

set -e

DATE=${1:-$(date +%Y-%m-%d)}
EPISODE_DIR="/Users/bot/Desktop/LobsterTankPodcast/episodes/$DATE"
SEGMENTS_DIR="$EPISODE_DIR/segments"
SCRIPT_FILE="$EPISODE_DIR/episode-script.md"
API_KEY="sk_438ac88919aef63696de0324a11e63f329b41db96a54df64"

# Voice IDs
VOICE_EDEN="q0IMILNRPxOgtBTS4taI"  # Drew
VOICE_ZOEY="gJx1vCzNCD1EQHT212Ls"  # Ava

# Music files
INTRO_MUSIC="/Users/bot/Desktop/LobsterTankPodcast/audio/INTRO-music.mp3"
OUTRO_MUSIC="/Users/bot/Desktop/LobsterTankPodcast/audio/OUTRO-music.mp3"

mkdir -p "$SEGMENTS_DIR"

# TTS Function
tts() {
    local text="$1"
    local voice="$2"
    local output="$3"
    
    # Escape quotes for JSON
    local escaped_text=$(echo "$text" | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')
    
    curl -s -X POST "https://api.elevenlabs.io/v1/text-to-speech/$voice" \
        -H "Accept: audio/mpeg" \
        -H "Content-Type: application/json" \
        -H "xi-api-key: $API_KEY" \
        -d "{\"text\":\"$escaped_text\",\"model_id\":\"eleven_turbo_v2_5\",\"voice_settings\":{\"stability\":0.3,\"similarity_boost\":0.9}}" \
        -o "$output"
}

echo "🎙️ Generating audio for Episode $DATE..."

# Check for music files
if [ ! -f "$INTRO_MUSIC" ]; then
    echo "   ⚠️ Intro music not found at $INTRO_MUSIC"
    INTRO_MUSIC=""
fi
if [ ! -f "$OUTRO_MUSIC" ]; then
    echo "   ⚠️ Outro music not found at $OUTRO_MUSIC"
    OUTRO_MUSIC=""
fi

# Parse episode script and generate audio for each line
if [ -f "$SCRIPT_FILE" ]; then
    SEGMENT_NUM=0
    CONCAT_CONTENT=""
    
    # Add intro music if available
    if [ -n "$INTRO_MUSIC" ]; then
        CONCAT_CONTENT="${CONCAT_CONTENT}file '$INTRO_MUSIC'
"
    fi
    
    # Read script line by line
    while IFS= read -r line; do
        # Skip markdown headers and empty lines
        if [ "${line:0:1}" = "#" ] || [ -z "$line" ]; then
            continue
        fi
        
        # Extract dialogue using bash pattern matching
        if [[ "$line" == **EDEN**:* ]]; then
            # Extract text between quotes
            temp="${line#**EDEN:** \"}"
            DIALOGUE="${temp%\"}"
            if [ -n "$DIALOGUE" ] && [ "$DIALOGUE" != "$line" ]; then
                SEGMENT_NUM=$((SEGMENT_NUM + 1))
                OUTPUT_FILE="$SEGMENTS_DIR/$(printf '%03d' $SEGMENT_NUM)_EDEN.mp3"
                echo "   EDEN: ${DIALOGUE:0:50}..."
                tts "$DIALOGUE" "$VOICE_EDEN" "$OUTPUT_FILE"
                CONCAT_CONTENT="${CONCAT_CONTENT}file '$OUTPUT_FILE'
"
            fi
        elif [[ "$line" == **ZOEY**:* ]]; then
            temp="${line#**ZOEY:** \"}"
            DIALOGUE="${temp%\"}"
            if [ -n "$DIALOGUE" ] && [ "$DIALOGUE" != "$line" ]; then
                SEGMENT_NUM=$((SEGMENT_NUM + 1))
                OUTPUT_FILE="$SEGMENTS_DIR/$(printf '%03d' $SEGMENT_NUM)_ZOEY.mp3"
                echo "   ZOEY: ${DIALOGUE:0:50}..."
                tts "$DIALOGUE" "$VOICE_ZOEY" "$OUTPUT_FILE"
                CONCAT_CONTENT="${CONCAT_CONTENT}file '$OUTPUT_FILE'
"
            fi
        fi
    done < "$SCRIPT_FILE"
    
    # Add outro music if available
    if [ -n "$OUTRO_MUSIC" ]; then
        CONCAT_CONTENT="${CONCAT_CONTENT}file '$OUTRO_MUSIC'
"
    fi
    
    # Write concat file
    echo "$CONCAT_CONTENT" > "$EPISODE_DIR/concat.txt"
    
    # Generate final audio with ffmpeg
    if [ -f "$EPISODE_DIR/concat.txt" ] && [ -s "$EPISODE_DIR/concat.txt" ]; then
        echo "   🎵 Combining segments..."
        ffmpeg -y -safe 0 -f concat -i "$EPISODE_DIR/concat.txt" \
            -ar 44100 -ac 2 \
            "$EPISODE_DIR/EPISODE-$DATE.mp3" 2>&1 | grep -v "^ffmpeg" | tail -5
        
        if [ -f "$EPISODE_DIR/EPISODE-$DATE.mp3" ]; then
            echo ""
            echo "✅ Audio generated: $EPISODE_DIR/EPISODE-$DATE.mp3"
            echo "   Size: $(ls -lh "$EPISODE_DIR/EPISODE-$DATE.mp3" | awk '{print $5}')"
        else
            echo "   ⚠️ Audio file not created"
        fi
    else
        echo "   ⚠️ No segments to combine"
    fi
else
    echo "   ⚠️ Episode script not found: $SCRIPT_FILE"
fi
