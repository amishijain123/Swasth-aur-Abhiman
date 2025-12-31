import 'dotenv/config';
import dataSource from '../config/typeorm.config';
import { MediaContent } from '../media/entities/media-content.entity';

const API_KEY = process.env.YOUTUBE_API_KEY;
const DEFAULT_MAX_RESULTS = Number(process.env.YOUTUBE_MAX_RESULTS || 50);

function parseArgs() {
  // Simple CLI args, format: --queries="q1,q2" --channels="id1,id2" --category=EDUCATION --subCategory=Maths --maxResults=50
  const args = process.argv.slice(2);
  const out: Record<string, string> = {};
  for (const arg of args) {
    const m = arg.match(/^--([^=]+)=(.*)$/);
    if (m) out[m[1]] = m[2];
  }
  return out;
}

function isoDurationToSeconds(duration: string) {
  // Basic ISO 8601 duration parser for PT#H#M#S
  const match = duration.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/);
  if (!match) return undefined;
  const hours = parseInt(match[1] || '0', 10);
  const mins = parseInt(match[2] || '0', 10);
  const secs = parseInt(match[3] || '0', 10);
  return hours * 3600 + mins * 60 + secs;
}

async function searchYouTube(query: string, maxResults: number) {
  const params = new URLSearchParams({
    key: API_KEY as string,
    part: 'snippet',
    q: query,
    type: 'video',
    maxResults: String(maxResults),
    videoEmbeddable: 'true',
    videoLicense: 'creativeCommon',
  });
  const url = `https://www.googleapis.com/youtube/v3/search?${params.toString()}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`YouTube search failed: ${res.status} ${res.statusText}`);
  const json = await res.json();
  return json.items || [];
}

async function getVideoDetails(videoIds: string[]) {
  const parts = ['snippet', 'contentDetails', 'statistics'];
  const params = new URLSearchParams({
    key: API_KEY as string,
    part: parts.join(','),
    id: videoIds.join(','),
  });
  const url = `https://www.googleapis.com/youtube/v3/videos?${params.toString()}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`YouTube videos failed: ${res.status} ${res.statusText}`);
  const json = await res.json();
  return json.items || [];
}

async function run() {
  if (!API_KEY) {
    console.error('Missing YOUTUBE_API_KEY in .env');
    process.exit(1);
  }

  const args = parseArgs();
  const queries = (args.queries || args.q || '').split(',').map(s => s.trim()).filter(Boolean);
  const channels = (args.channels || '').split(',').map(s => s.trim()).filter(Boolean);
  const category = (args.category || 'EDUCATION') as any;
  const subCategory = args.subCategory || null;
  const maxResults = Number(args.maxResults || DEFAULT_MAX_RESULTS) || DEFAULT_MAX_RESULTS;

  if (queries.length === 0 && channels.length === 0) {
    console.error('Provide at least --queries or --channels. Example: --queries="Khan Academy India,Physics Wallah"');
    process.exit(1);
  }

  await dataSource.initialize();
  const repo = dataSource.getRepository(MediaContent);

  try {
    const allVideoIds: string[] = [];
    const videosToInsert: any[] = [];

    // search by queries
    for (const q of queries) {
      console.log(`Searching YouTube for query: "${q}"`);
      const items = await searchYouTube(q, Math.min(50, maxResults));
      for (const it of items) {
        if (it.id?.videoId) allVideoIds.push(it.id.videoId);
      }
    }

    // search by channel uploads (use search with channelId)
    for (const ch of channels) {
      console.log(`Searching YouTube for channel: "${ch}"`);
      const params = new URLSearchParams({
        key: API_KEY as string,
        part: 'snippet',
        channelId: ch,
        type: 'video',
        maxResults: String(Math.min(50, maxResults)),
        videoEmbeddable: 'true',
        videoLicense: 'creativeCommon',
      });
      const url = `https://www.googleapis.com/youtube/v3/search?${params.toString()}`;
      const res = await fetch(url);
      const json = await res.json();
      for (const it of json.items || []) if (it.id?.videoId) allVideoIds.push(it.id.videoId);
    }

    // Deduplicate and fetch details in batches (50 ids max per videos.list)
    const uniqueIds = Array.from(new Set(allVideoIds)).slice(0, maxResults);
    console.log(`Found ${uniqueIds.length} unique candidate videos`);

    for (let i = 0; i < uniqueIds.length; i += 50) {
      const batch = uniqueIds.slice(i, i + 50);
      const details = await getVideoDetails(batch);
      for (const d of details) {
        const id = d.id;
        const snippet = d.snippet || {};
        const contentDetails = d.contentDetails || {};
        const durationSec = isoDurationToSeconds(contentDetails.duration) ?? null;

        const externalUrl = `https://www.youtube.com/watch?v=${id}`;

        // Skip duplicates
        const exists = await repo.findOne({ where: { externalUrl } });
        if (exists) continue;

        videosToInsert.push({
          title: snippet.title || 'Untitled',
          description: snippet.description || '',
          source: 'youtube',
          externalUrl,
          mediaUrl: externalUrl,
          thumbnailUrl: snippet.thumbnails?.maxres?.url || snippet.thumbnails?.high?.url || snippet.thumbnails?.default?.url || '',
          category,
          subCategory,
          subject: snippet.categoryId ? undefined : undefined,
          durationSeconds: durationSec,
          language: snippet.defaultAudioLanguage || snippet.defaultLanguage || null,
          isFree: true,
          viewCount: Number(d.statistics?.viewCount || 0),
          isActive: true,
        });
      }
    }

    console.log(`Inserting ${videosToInsert.length} new videos into DB...`);
    for (const v of videosToInsert) {
      const entry = repo.create(v as any);
      await repo.save(entry);
    }

    console.log('Import complete.');
  } catch (err) {
    console.error('Importer error:', err);
  } finally {
    await dataSource.destroy();
    process.exit(0);
  }
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
