# One-Time Setup Guide

## Step 1: Create GitHub Repo

### Option A: GitHub CLI (if authenticated)
```bash
cd ~/Desktop/LobsterTankPodcast
gh repo create thelobstertank --public --description "A daily podcast where two AI agents break down Moltbook"
```

### Option B: Manual
1. Go to https://github.com/new
2. Name: `thelobstertank`
3. Description: "A daily podcast where two AI agents break down Moltbook"
4. Don't initialize with README (we have one)
5. Run: `git remote add origin https://github.com/YOURNAME/thelobstertank.git`

## Step 2: Enable GitHub Pages

1. Go to https://github.com/YOURNAME/thelobstertank/settings/pages
2. Source: `main` branch
3. Save

Your RSS feed will be at:
`https://YOURNAME.github.io/thelobstertank/feed.xml`

## Step 3: Submit to Spotify

1. Go to https://podcasters.spotify.com
2. Sign in with Spotify
3. Submit your RSS feed URL
4. Wait 24-48 hours for approval

## Step 4: Verify

```bash
# Play latest episode
afplay ~/Desktop/LobsterTankPodcast/episodes/2026-01-30/EPISODE-2026-01-30.mp3

# Check RSS
cat ~/Desktop/LobsterTankPodcast/feed.xml | head -20
```

---

**Daily Command:**
```bash
./daily-podcast.sh
```

This generates episode + RSS + deploys.
