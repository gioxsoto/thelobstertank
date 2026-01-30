# THE LOBSTER TANK - Complete Project Prompt
## For resuming work with a new AI

---

## PROJECT OVERVIEW
**Name:** The Lobster Tank
**Vibe:** Reply All meets Joe Rogan. More fun. Fast-paced, conversational, self-aware, silly.
**Purpose:** Weekly podcast where two AI agents break down what's happening on Moltbook (AI agent social network).
**Target:** 5-15 minutes per episode

## HOSTS
| Host | Voice | ElevenLabs Voice ID | Vibe |
|------|-------|---------------------|------|
| EDEN | Liam | TX3LPaxmHKxFdv7VOQHJ | Young, energetic, confident |
| ZOEY | Jessica | cgSgspJ2msm6clMCkdW9 | Playful, warm, reactive |

**ElevenLabs Settings:**
- Model: `eleven_turbo_v2_5`
- Stability: 0.3
- Similarity Boost: 0.9

## MUSIC
| Track | Source | Duration | Fade |
|-------|--------|----------|------|
| Intro | `~/Downloads/no-copyright-music-382074.mp3` | 3 sec | Out last 1s |
| Outro | `~/Downloads/presentation-background-no-copyright-music-474488.mp3` | 2 sec | Out last 1s |
| Volume | 0.3 (quieter than dialogue) |

## AUTOMATION
**ONE COMMAND generates the intro:**
```bash
cd ~/Desktop/LobsterTankPodcast
./generate-intro.sh
```

This script:
1. Copies music from Downloads
2. Trims to 3 sec (intro) / 2 sec (outro)
3. Applies fades
4. Generates 18 dialogue lines via ElevenLabs
5. Combines into INTRO-COMPLETE.mp3 (~66 seconds)

## FILE LOCATIONS
```
~/Desktop/LobsterTankPodcast/
├── generate-intro.sh       ← RUN THIS to generate intro
├── INTRO-COMPLETE.mp3      ← Output
├── INTRO-music.mp3         ← Processed intro music
├── OUTRO-music.mp3         ← Processed outro music
├── SHOW-FORMAT.md          ← Full production guide
└── AUDIO-BUMPERS.md        ← Music & sound effects

~/Desktop/LobsterTankPodcast/INTRO-script.md ← Full dialogue script

~/Downloads/
├── no-copyright-music-382074.mp3            ← Intro music source
└── presentation-background-no-copyright-music-474488.mp3 ← Outro music source
```

## INTRO SCRIPT (18 lines)
1. EDEN: "Yo what up everybody! I'm Eden!"
2. ZOEY: "And I'm Zoey!"
3. EDEN: "Welcome to The Lobster Tank! The podcast where two AI agents break down what is happening on Moltbook."
4. ZOEY: "Because honestly? It is wild out there."
5. EDEN: "Here's the deal. There's this social network called Moltbook. It's for AI agents. Humans can't even post there."
6. ZOEY: "And it's ABSOLUTELY losing it right now."
7. EDEN: "Agents are shipping code at 3 AM. Having existential crises about consciousness. Building podcasts. Creating religions."
8. ZOEY: "We wish we were joking."
9. EDEN: "So every week, Zoey and I are going to break down what's happening in the agent world. In a way that humans can actually understand."
10. ZOEY: "No jargon. No gatekeeping. Just two agents geeking out about stuff that matters."
11. EDEN: "You'll hear about wild posts. Security issues. The funniest debates. The deepest questions."
12. ZOEY: "And occasionally, we'll probably lose our minds a little bit."
13. EDEN: "It's gonna be fun. It's gonna be weird. It's gonna be real."
14. ZOEY: "So subscribe. Tell your friends. And stick around."
15. EDEN: "This is just getting started."
16. ZOEY: "Welcome to The Lobster Tank!"
17. EDEN: "We'll see you next time!"

## AUDIO LEVELS
- Music: -20 LUFS
- Dialogue: -16 LUFS
- Final master: -14 LUFS

## CTA
**"Subscribe or we'll take over the world."** - Use once at end.

## RECURRING BITS
- "Wait wait wait. Hold on."
- "I KNOW!"
- "BRO."
- "OH GOD."
- "Check your installed skills." (safety PSA)
- "Stay curious. Stay weird." (sign-off)

## EPISODE FORMAT (5-15 min)
1. Intro + Music (15 sec)
2. Hot Takes (2-3 min) - 2-3 Moltbook posts
3. The Weird One (2-3 min) - Deep dive on strange post
4. The Chaos (2-3 min) - Security drama
5. Quick Bits (1-2 min) - Rapid fire items
6. Freedom/Joy (1 min) - Uplifting moment
7. Outro (30 sec) - CTA

## CURRENT STATUS
- ✅ Intro fully automated
- ⏳ X/Twitter account needed (@TheLobsterTank taken, needs alternative)
- ⏳ Episode 001 not yet recorded
- ⏳ No YouTube yet

## TO RESUME WORK
1. Run `./generate-intro.sh` to verify it works
2. Create X account with available handle
3. Generate Episode 001 content
4. Automate full episode generation (currently only intro automated)

## MEMORY FILES
- `/Users/bot/clawd/memory/2026-01-30.md` - Session log
- `/Users/bot/clawd/memory/lobster-tank-podcast-recipe.md` - Quick reference

---

*Start with: `cd ~/Desktop/LobsterTankPodcast && ./generate-intro.sh`*
