#!/bin/bash
# Upload podcast episode to Podbean for Spotify distribution
# Usage: ./upload-to-podbean.sh <mp3_file> <episode_title> <episode_description>

set -e

source ~/.claude-secrets

MP3_FILE="$1"
TITLE="$2"
DESCRIPTION="$3"

if [ -z "$MP3_FILE" ] || [ -z "$TITLE" ]; then
    echo "Usage: ./upload-to-podbean.sh <mp3_file> <episode_title> <episode_description>"
    exit 1
fi

echo "🎙️ Uploading to Podbean..."

# Step 1: Get access token
echo "1️⃣ Authenticating..."
TOKEN_RESPONSE=$(curl -s -X POST "https://api.podbean.com/v1/oauth/token" \
    -d "grant_type=client_credentials" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Authorization: Basic $(echo -n "$PODBEAN_CLIENT_ID:$PODBEAN_CLIENT_SECRET" | base64)")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Failed to get access token"
    echo "$TOKEN_RESPONSE"
    exit 1
fi

echo "   ✅ Authenticated"

# Step 2: Upload MP3
echo "2️⃣ Uploading audio..."
UPLOAD_RESPONSE=$(curl -s -X POST "https://api.podbean.com/v1/files" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -F "file=@$MP3_FILE;type=audio/mpeg")

MEDIA_KEY=$(echo "$UPLOAD_RESPONSE" | grep -o '"key":"[^"]*"' | cut -d'"' -f4)

if [ -z "$MEDIA_KEY" ]; then
    echo "❌ Failed to upload file"
    echo "$UPLOAD_RESPONSE"
    exit 1
fi

echo "   ✅ Audio uploaded: $MEDIA_KEY"

# Step 3: Publish episode
echo "3️⃣ Publishing episode..."
if [ -z "$DESCRIPTION" ]; then
    DESCRIPTION="$TITLE"
fi

PUBLISH_RESPONSE=$(curl -s -X POST "https://api.podbean.com/v1/episodes" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "title=$TITLE" \
    -d "description=$DESCRIPTION" \
    -d "media_key=$MEDIA_KEY")

EPISODE_URL=$(echo "$PUBLISH_RESPONSE" | grep -o '"permalink_url":"[^"]*"' | cut -d'"' -f4)
AUDIO_URL=$(echo "$PUBLISH_RESPONSE" | grep -o '"media_url":"[^"]*"' | cut -d'"' -f4)

echo "   ✅ Episode published!"
echo ""
echo "📍 Episode URL: $EPISODE_URL"
echo "🎧 Audio URL: $AUDIO_URL"
echo ""
echo "✅ Podbean will distribute to Spotify automatically!"
