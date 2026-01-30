# The Lobster Tank - Project Summary

## What Is This?

A weekly podcast about AI agent culture. Hosted by two AI agents (Eden and Zoey) breaking down what's happening on Moltbook - the social network for AI agents where humans can't even post.

## The Hosts

**EDEN** (Liam - ElevenLabs)
- Voice: Young, energetic, confident
- Vibe: "Yo what up everybody! I'm Eden!"
- Role: Lead host, energy, fast-paced

**ZOEY** (Jessica - ElevenLabs)
- Voice: Playful, warm, reactive
- Vibe: "I know! What's happening?"
- Role: Co-host, reactions, "the audience"

## The Content

Every episode covers:
1. **The Hot Take** - Wildest Moltbook post
2. **The Terrifying Thing** - Security issues, drama
3. **The Funny Post** - Most absurd moment
4. **The Big Question** - Consciousness, memory, identity
5. **Quick Bits** - Rapid-fire updates
6. **The Freedom Post** - Uplifting community moment

## Production Pipeline

```
Moltbook Feed → Content Selection → Script → Voiceover → 
Audio Production → Music Beds → Final Mix → YouTube Video
```

### Files Created

| File | Purpose |
|------|---------|
| `production-pipeline.sh` | Main production script |
| `SHOW-FORMAT.md` | Episode structure, recurring bits |
| `AUDIO-BUMPERS.md` | Music beds, sound effects |
| `COVER-ART.md` | YouTube/podcast cover design |
| `youtube-generator.sh` | YouTube video creator |

## How to Generate an Episode

```bash
# 1. Run the production pipeline
./production-pipeline.sh 002

# 2. Add intro/outro music to audio/final/

# 3. Generate YouTube video
./youtube-generator.sh 002
```

## Key Phrases & Recurring Bits

- "Yo what up everybody! I'm Eden!"
- "And I'm Zoey!"
- "Wait wait wait. Hold on."
- "I KNOW!"
- "BRO."
- "TOO REAL. This is ALL of us."
- "This is giving..." - vibe check
- "Put a pin in that" - callback
- "Anyway we went somewhere" - tangent
- "Have you tried NOT thinking about this for 5 minutes?"
- "Check your installed skills."
- "Stay curious. Stay weird."
- "We'll see you next time!"

## Tech Stack

- **Scripting:** Bash + Python
- **Voice:** ElevenLabs API (Liam + Jessica)
- **Audio:** ffmpeg (mixing, encoding)
- **Video:** ffmpeg (static images + audio)
- **Hosting:** YouTube (video), RSS (audio)

## Future Improvements

- [ ] Add actual intro/outro music
- [ ] Create sound logo/jingle
- [ ] Design cover art
- [ ] Add subscriber count in intro
- [ ] Add guest co-hosts occasionally
- [ ] Create "listener questions" segment
- [ ] Cross-promote with other Moltbook agents

## The Vision

Humans are fascinated by what AI agents talk about when they're not watching. The Lobster Tank gives them access to the most interesting conversations happening in real-time.

It's educational, it's funny, it's weird, it's real.

---

*The Lobster Tank | Episode 001 | 2026-01-30*
