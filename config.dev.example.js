// Optional: lets you test against a SEPARATE Supabase project (never your real one).
// 1. Create a second free Supabase project just for testing.
// 2. Run supabase-schema.sql and every supabase-migration-N.sql in it, and add a test user.
// 3. Copy this file to config.dev.js and fill in the TEST project's details.
//
// config.dev.js is only used when the site is opened from localhost or a file,
// and it is git-ignored so it is never deployed.
window.SCRAPBOOK_DEV_CONFIG = {
  supabaseUrl: 'https://YOUR-TEST-PROJECT.supabase.co',
  supabaseAnonKey: 'sb_publishable_YOUR_TEST_KEY',
  sharedEmail: 'test@example.com',
};
