# Our Scrapbook

A private, scroll-based scrapbook for memories: photos, videos, voice notes, songs, comments,
reactions, lists, a map, and a photo-book export. Static site (HTML/CSS/JS) backed by Supabase.

- **`index.html`**: the whole app.
- **`config.js`**: Supabase URL, *publishable* key and the shared sign-in email. The publishable key is
  designed to be public; row-level security and the sign-in protect the data.
- **`supabase-schema.sql`, `supabase-migration-N.sql`**: database setup, run in order in Supabase's SQL editor.
- **`SAFE_CHANGES.md`**: how to change the site without risking the data, and how to restore anything.

Opened from `localhost` it runs on browser-only practice data (or a test project named in
`config.dev.js`), never the real database. See `SAFE_CHANGES.md`.

Never commit a Supabase `service_role` / secret key or the sign-in password.
