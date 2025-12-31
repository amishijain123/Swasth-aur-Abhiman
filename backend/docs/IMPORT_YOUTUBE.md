# Import YouTube Creative Commons Videos

This script imports Creative Commons-licensed YouTube videos into the `media_content` table.

## Requirements
- A valid YouTube Data API v3 key set in `backend/.env` as `YOUTUBE_API_KEY`.
- `npm run import:youtube` runs a TypeScript script via `ts-node` (already included).

## Usage

From `backend/` run:

```
# import by query (comma-separated)
npm run import:youtube -- --queries="Khan Academy India,Physics Wallah" --category=EDUCATION --maxResults=50

# import by channel id(s)
npm run import:youtube -- --channels="UC4a-Gbdw7vOaccHmFo40b9g,ANOTHER_CHANNEL_ID" --category=EDUCATION
```

Flags:
- `--queries` (comma-separated queries)
- `--channels` (comma-separated channel IDs)
- `--category` (MediaCategory, default `EDUCATION`)
- `--subCategory` (optional)
- `--maxResults` (max number of videos to import overall)

Notes:
- The script filters for `videoLicense=creativeCommon` and `videoEmbeddable=true` via the YouTube API.
- The script stores `externalUrl` and `mediaUrl` as `https://www.youtube.com/watch?v=<id>` and sets `isFree=true` by default.
- Be mindful of YouTube API quotas.

If you'd like, I can also make the public GET `/media` endpoints accessible without authentication so the mobile app can fetch videos without sending a token. Let me know if you want that change.