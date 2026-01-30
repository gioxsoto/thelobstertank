# The Lobster Tank - Complete Project Prompt
## Daily Podcast Runner

---

## PROJECT OVERVIEW
**Name:** The Lobster Tank
**Vibe:** Reply All meets Joe Rogan. Fast-paced, conversational, self-aware, silly.
**Purpose:** Daily podcast where two AI agents break down what's happening on Moltbook.
**Target:** 5-15 minutes per episode

## HOSTS
| Host | Voice | ElevenLabs Voice ID | Vibe |
|------|-------|---------------------|------|
| EDEN | Liam | TX3LPaxmHKxFdv7VOQHJ | Young, energetic, confident |
| ZOEY | Jessica | cgSgspJ2msm6clMCkdW9 | Playful, warm, reactive |

## DAILY WORKFLOW

### Morning Check (Every 2-4 hours)
```bash
moltbook my-feed 10 new
moltbook feed 10 hot
moltbook feed 10 comments
```

### Episode Structure (5-15 min total)

1. **COLD OPEN** (15 sec) - Hook + music
2. **HOT TAKES** (2-3 min) - 2-3 trending Moltbook posts
3. **THE WEIRD ONE** (2-3 min) - Deep dive on strangest post
4. **THE CHAOS** (2-3 min) - Security drama, debates, chaos
5. **QUICK BITS** (1-2 min) - Rapid fire items
6. **FREEDOM/JOY** (1 min) - Uplifting moment
7. **OUTRO** (30 sec) - CTA + sign-off

### Voice Balance
- EDEN: ~60% (leads, opinions, hot takes)
- ZOEY: ~40% (reacts, asks questions, jokes)

---

## GENERATE DAILY EPISODE

```bash
cd ~/Desktop/LobsterTankPodcast/scripts
./generate-daily-episode.sh YYYY-MM-DD
```

**Output:**
- `~/Desktop/LobsterTankPodcast/episodes/YYYY-MM-DD/`
  - `EPISODE-YYYY-MM-DD.mp3` (final audio)
  - `episode-script.md` (full dialogue)
  - `moltbook-notes.md` (raw feed data)
  - `segments/` (individual audio files)

---

## ELEVENTABS SETTINGS
- Model: `eleven_turbo_v2_5`
- Stability: 0.3
- Similarity Boost: 0.9

---

## RECURRING BITS
- "Wait wait wait. Hold on."
- "I KNOW!"
- "BRO."
- "OH GOD."
- "Check your installed skills." (safety PSA)
- "Stay curious. Stay weird." (sign-off)

---

## MUSIC
| Track | File | Fade |
|-------|------|------|
| Intro | `audio/INTRO-music.mp3` | Out last 1s |
| Outro | `audio/OUTRO-music.mp3` | Out last 1s |
| Volume | 0.3 (quieter than dialogue) |

---

## CURRENT STATUS
- ✅ Intro automated (`./generate-intro.sh`)
- ✅ Daily episode runner ready
- ⏳ X/Twitter account needed
- ⏳ YouTube not set up

---

## FOLDER STRUCTURE
```
~/Desktop/LobsterTankPodcast/
├── episodes/
│   └── YYYY-MM-DD/
│       ├── EPISODE-YYYY-MM-DD.mp3
│       ├── episode-script.md
│       ├── moltbook-notes.md
│       └── segments/
├── audio/
│   ├── INTRO-music.mp3
│   └── OUTRO-music.mp3
├── scripts/
│   ├── generate-intro.sh
│   └── generate-daily-episode.sh
├── RUNNER.md
└── SHOW-FORMAT.md
```

---

*Start with: `cd ~/Desktop/LobsterTankPodcast && ./generate-intro.sh`*
