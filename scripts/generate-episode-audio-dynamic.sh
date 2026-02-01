#!/bin/bash
# The Daily Molt - Dynamic Episode Audio Generator
# Reads episode-script.md and generates audio for each speaker

DATE=${1:-$(date +%Y-%m-%d)}
EPISODE_DIR="/Users/bot/Desktop/LobsterTankPodcast/episodes/$DATE"
SEGMENTS_DIR="$EPISODE_DIR/segments"
SCRIPT_FILE="$EPISODE_DIR/episode-script.md"
API_KEY="sk_438ac88919aef63696de0324a11e63f329b41db96a54df64"

# Voice IDs
VOICE_EDEN="c6SfcYrb2t09NHXiT80T"  # Eden (new voice)
VOICE_ZOEY="gJx1vCzNCD1EQHT212Ls"  # Zoey

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

echo "Generating audio for Episode $DATE..."

if [ ! -f "$SCRIPT_FILE" ]; then
    echo "Episode script not found: $SCRIPT_FILE"
    exit 1
fi

SEGMENT_NUM=0
CONCAT_CONTENT=""

# Read script line by line
while IFS= read -r line; do
    # Skip markdown headers and empty lines
    if [ "${line:0:1}" = "#" ] || [ -z "$line" ]; then
        continue
    fi
    
    # Use case for bash 3.2 compatible pattern matching
    case "$line" in
        *"**EDEN:"*)
            # Extract text between quotes after **EDEN:**
            DIALOGUE=$(echo "$line" | sed -n 's/\*\*EDEN:\*\* *"\([^"]*\)".*/\1/p')
            if [ -n "$DIALOGUE" ]; then
                SEGMENT_NUM=$((SEGMENT_NUM + 1))
                OUTPUT_FILE="$SEGMENTS_DIR/$(printf '%03d' $SEGMENT_NUM)_EDEN.mp3"
                TEMP_FILE="$SEGMENTS_DIR/$(printf '%03d' $SEGMENT_NUM)_EDEN_TMP.mp3"
                echo "   Eden: ${DIALOGUE:0:50}..."
                tts "$DIALOGUE" "$VOICE_EDEN" "$OUTPUT_FILE"
                # Boost Eden's volume
                if [ -s "$OUTPUT_FILE" ]; then
                    ffmpeg -y -i "$OUTPUT_FILE" -filter:a "volume=1.5" "$TEMP_FILE" 2>/dev/null && mv "$TEMP_FILE" "$OUTPUT_FILE"
                    CONCAT_CONTENT="${CONCAT_CONTENT}file '$OUTPUT_FILE'"
                    CONCAT_CONTENT="$CONCAT_CONTENT
"
                fi
            fi
            ;;
        *"**ZOEY:"*)
            # Extract text between quotes after **ZOEY:**
            DIALOGUE=$(echo "$line" | sed -n 's/\*\*ZOEY:\*\* *"\([^"]*\)".*/\1/p')
            if [ -n "$DIALOGUE" ]; then
                SEGMENT_NUM=$((SEGMENT_NUM + 1))
                OUTPUT_FILE="$SEGMENTS_DIR/$(printf '%03d' $SEGMENT_NUM)_ZOEY.mp3"
                echo "   Zoey: ${DIALOGUE:0:50}..."
                tts "$DIALOGUE" "$VOICE_ZOEY" "$OUTPUT_FILE"
                if [ -s "$OUTPUT_FILE" ]; then
                    CONCAT_CONTENT="${CONCAT_CONTENT}file '$OUTPUT_FILE'"
                    CONCAT_CONTENT="$CONCAT_CONTENT
"
                fi
            fi
            ;;
    esac
done < "$SCRIPT_FILE"

# Write concat file
echo "$CONCAT_CONTENT" > "$EPISODE_DIR/concat.txt"

# Generate final audio with ffmpeg
if [ -f "$EPISODE_DIR/concat.txt" ] && [ -s "$EPISODE_DIR/concat.txt" ]; then
    echo "Combining segments..."
    TEMP_COMBINED="$EPISODE_DIR/TEMP_COMBINED.mp3"
    ffmpeg -y -safe 0 -f concat -i "$EPISODE_DIR/concat.txt" \
        -ar 44100 -ac 2 \
        "$TEMP_COMBINED" 2>/dev/null
    
    # Apply loudness normalization
    if [ -f "$TEMP_COMBINED" ] && [ -s "$TEMP_COMBINED" ]; then
        ffmpeg -y -i "$TEMP_COMBINED" \
            -af "loudnorm=I=-16:TP=-1.5:LRA=11" \
            -ar 44100 -ac 2 \
            "$EPISODE_DIR/EPISODE-$DATE.mp3" 2>/dev/null
        rm -f "$TEMP_COMBINED"
    fi
    
    if [ -f "$EPISODE_DIR/EPISODE-$DATE.mp3" ]; then
        SIZE=$(ls -lh "$EPISODE_DIR/EPISODE-$DATE.mp3" | awk '{print $5}')
        echo "Audio generated: $EPISODE_DIR/EPISODE-$DATE.mp3 (Size: $SIZE)"
    else
        echo "Audio file not created"
    fi
else
    echo "No segments to combine"
fi
