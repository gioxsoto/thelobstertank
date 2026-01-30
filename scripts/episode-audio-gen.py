#!/usr/bin/env python3
"""
The Lobster Tank - Episode Generator
Generates podcast audio from dialogue script using ElevenLabs
"""

import os
import json
import requests
import subprocess
from datetime import datetime

# Config
OUTPUT_DIR = "/Users/bot/Desktop/LobsterTankPodcast/episodes/001"
AUDIO_DIR = f"{OUTPUT_DIR}/segments"
API_URL = "https://api.elevenlabs.io/v1/text-to-speech"
VOICES = {
    "EDEN": "TX3LPaxmHKxFdv7VOQHJ",  # Liam (male, clear)
    "ZOEY": "cgSgspJ2msm6clMCkdW9",  # Jessica (female, warm)
}
API_KEY = os.environ.get("ELEVENLABS_API_KEY", "sk_3765c88a7380273f2c20a803906b91c49b770f70b0f2a7f5a7e5e3c1d8e4b9a3")

# Ensure directories exist
os.makedirs(AUDIO_DIR, exist_ok=True)

def text_to_speech(text, voice_id, filename):
    """Convert text to speech using ElevenLabs"""
    url = f"{API_URL}/{voice_id}"
    headers = {
        "Accept": "audio/mpeg",
        "Content-Type": "application/json",
        "xi-api-key": API_KEY
    }
    data = {
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75
        }
    }
    
    response = requests.post(url, json=data, headers=headers)
    
    if response.status_code == 200:
        with open(filename, "wb") as f:
            f.write(response.content)
        return True
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return False

def parse_script(script_path):
    """Parse dialogue script into segments"""
    segments = []
    
    with open(script_path, 'r') as f:
        lines = f.readlines()
    
    current_speaker = None
    current_text = []
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
        
        # Check for speaker
        if line in VOICES.keys():
            if current_speaker and current_text:
                segments.append({
                    "speaker": current_speaker,
                    "text": " ".join(current_text)
                })
            current_speaker = line
            current_text = []
        else:
            current_text.append(line)
    
    # Don't forget last segment
    if current_speaker and current_text:
        segments.append({
            "speaker": current_speaker,
            "text": " ".join(current_text)
        })
    
    return segments

def main():
    script_path = f"{OUTPUT_DIR}/episode-script.md"
    
    print("Parsing script...")
    segments = parse_script(script_path)
    print(f"Found {len(segments)} segments")
    
    print("\nGenerating audio segments...")
    for i, seg in enumerate(segments):
        filename = f"{AUDIO_DIR}/{i:03d}_{seg['speaker']}.mp3"
        print(f"  [{i+1}/{len(segments)}] {seg['speaker']}: {seg['text'][:50]}...")
        
        success = text_to_speech(
            seg["text"],
            VOICES[seg["speaker"]],
            filename
        )
        
        if not success:
            print(f"  Failed to generate audio for segment {i}")
    
    print(f"\nAudio segments saved to {AUDIO_DIR}")
    print("Next: Combine segments with intro/outro music")

if __name__ == "__main__":
    main()
