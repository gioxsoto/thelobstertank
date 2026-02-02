#!/bin/bash
# The Daily Molt - Dynamic Episode Audio Generator
# Reads episode-script.md and generates audio with intro/outro music

DATE=${1:-$(date +%Y-%m-%d)}
EPISODE_DIR="/Users/bot/Desktop/LobsterTankPodcast/episodes/$DATE"
SEGMENTS_DIR="$EPISODE_DIR/segments"
SCRIPT_FILE="$EPISODE_DIR/episode-script.md"
PODCAST_DIR="/Users/bot/Desktop/LobsterTankPodcast"

# Load API key from environment or fall back to hardcoded
source ~/.claude-secrets 2>/dev/null || true
API_KEY="${ELEVENLABS_API_KEY:-sk_438ac88919aef63696de0324a11e63f329b41db96a54df64}"

# Voice IDs
VOICE_EDEN="c6SfcYrb2t09NHXiT80T"  # Eden
VOICE_ZOEY="gJx1vCzNCD1EQHT212Ls"  # Zoey

# Music files
INTRO_MUSIC="$PODCAST_DIR/audio/INTRO-music.mp3"
OUTRO_MUSIC="$PODCAST_DIR/audio/OUTRO-music.mp3"

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

# Check for intro music
if [ -f "$INTRO_MUSIC" ]; then
    echo "   Using intro: $INTRO_MUSIC"
else
    echo "   No intro music found"
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
            DIALOGUE=$(echo "$line" | sed -n 's/\*\*EDEN:\*\* *"\([^"]*\)".*/\1/p')
            if [ -n "$DIALOGUE" ]; then
                SEGMENT_NUM=$((SEGMENT_NUM + 1))
                OUTPUT_FILE="$SEGMENTS_DIR/$(printf '%03d' $SEGMENT_NUM)_EDEN.mp3"
                TEMP_FILE="$SEGMENTS_DIR/$(printf '%03d' $SEGMENT_NUM)_EDEN_TMP.mp3"
                echo "   Eden: ${DIALOGUE:0:50}..."
                tts "$DIALOGUE" "$VOICE_EDEN" "$OUTPUT_FILE"
                if [ -s "$OUTPUT_FILE" ]; then
                    ffmpeg -y -i "$OUTPUT_FILE" -filter:a "volume=1.5" "$TEMP_FILE" 2>/dev/null && mv "$TEMP_FILE" "$OUTPUT_FILE"
                    CONCAT_CONTENT="${CONCAT_CONTENT}file '$OUTPUT_FILE'"
                    CONCAT_CONTENT="$CONCAT_CONTENT
"
                fi
            fi
            ;;
        *"**ZOEY:"*)
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
    echo "Combining dialogue segments..."

    # Combine dialogue segments
    TEMP_COMBINED="$EPISODE_DIR/TEMP_COMBINED.mp3"
    ffmpeg -y -safe 0 -f concat -i "$EPISODE_DIR/concat.txt" \
        -ar 44100 -ac 2 \
        "$TEMP_COMBINED" 2>/dev/null

    # Apply loudness normalization to dialogue
    if [ -f "$TEMP_COMBINED" ] && [ -s "$TEMP_COMBINED" ]; then
        ffmpeg -y -i "$TEMP_COMBINED" \
            -af "loudnorm=I=-16:TP=-1.5:LRA=11" \
            -ar 44100 -ac 2 \
            "$EPISODE_DIR/TEMP_DIALOGUE.mp3" 2>/dev/null
        rm -f "$TEMP_COMBINED"
    fi

    # Build final episode with intro and outro
    echo "Adding intro/outro..."

    FINAL_FILE="$EPISODE_DIR/EPISODE-$DATE.mp3"

    if [ -f "$INTRO_MUSIC" ] && [ -f "$EPISODE_DIR/TEMP_DIALOGUE.mp3" ] && [ -f "$OUTRO_MUSIC" ]; then
        # INTRO: 4 sec music, then fade out while dialogue fades in (no music under dialogue)
        # OUTRO: Dialogue fades out, outro music plays

        # Calculate fade out start time (2 seconds before end of dialogue)
        DIALOGUE_DUR=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$EPISODE_DIR/TEMP_DIALOGUE.mp3")
        FADE_OUT_START=$(echo "$DIALOGUE_DUR - 2" | bc)

        # 4 sec intro music, fades out over 2 sec while dialogue fades in over 2 sec
        ffmpeg -y -i "$INTRO_MUSIC" -i "$EPISODE_DIR/TEMP_DIALOGUE.mp3" -i "$OUTRO_MUSIC" \
            -filter_complex "[0:a]atrim=0:4,afade=t=out:st=2:d=2[a0];[1:a]afade=t=in:st=0:d=2,afade=t=out:st=$FADE_OUT_START:d=2[a1];[2:a]atrim=0:10,afade=t=in:st=0:d=1[a2];[a0][a1][a2]concat=n=3:v=0:a=1[out]" \
            -map "[out]" \
            "$FINAL_FILE" 2>/dev/null
    else
        cp "$EPISODE_DIR/TEMP_DIALOGUE.mp3" "$FINAL_FILE"
    fi

    # Cleanup temp files
    rm -f "$EPISODE_DIR/TEMP_COMBINED.mp3" "$EPISODE_DIR/TEMP_DIALOGUE.mp3" 2>/dev/null

    if [ -f "$FINAL_FILE" ]; then
        SIZE=$(ls -lh "$FINAL_FILE" | awk '{print $5}')
        DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FINAL_FILE" 2>/dev/null || echo "0")
        echo "Audio generated: $FINAL_FILE (Size: $SIZE, Duration: ${DURATION%.*} sec)"
    else
        echo "Audio file not created"
    fi
else
    echo "No segments to combine"
fi
