# Changing the site without hurting your data

The website (these files, hosted on GitHub Pages) and the data (your Supabase project) are separate.
Re-deploying or editing the site never touches the data by itself. Data is only at risk from a
**bug in new code** or a **bad database change**. The layers below cover both.

## Safety layers already in place

| Layer | What it does |
|---|---|
| **Test mode on your computer** | Opened from `localhost` or a file, the site ignores `config.js` and uses practice data stored only in that browser. A green "TEST MODE" bar shows when this is on. The live database can't be reached from your computer by accident. |
| **`row_history` (migration 4)** | Every UPDATE or DELETE on memories, comments, reactions, lists, list items and settings saves the old row first. Nothing is ever truly lost, and the website can't erase the history. |
| **Photos are never deleted** | The site no longer deletes files from storage, even when a memory is deleted. A buggy delete can't destroy photos. |
| **Backup button** | Settings → *Download a full backup* gives a `.zip` with all data and every photo. Do it before any big change, and now and then anyway. |
| **Row-level security** | Only signed-in users can read or write anything. |

## Safe workflow for any change

1. **Back up**: Settings → *Download a full backup*.
2. **Try it in test mode**: run the site locally (it uses practice data, so nothing real is touched).
   Want realistic testing? Make a second free Supabase project, run the migration files in it, copy
   `config.dev.example.js` to `config.dev.js`, and fill in the test project's URL and key.
   `config.dev.js` is git-ignored and is never deployed.
3. **Database changes go first and must be additive**: only add tables/columns (`add column if not exists`).
   Never drop or rename a column that the live site still uses. Run the SQL in Supabase **before** deploying
   the site code that needs it. Old open tabs keep working because nothing they use has gone away.
4. **Deploy** by pushing to the main branch. GitHub Pages publishes it within a minute.
5. **Something wrong?** Roll the site back with `git revert` (or redeploy the previous commit). The data is untouched.

## Putting damaged data back

Open Supabase → SQL Editor. See what changed recently:

```sql
select id, table_name, op, changed_at, row_data
from public.row_history
order by changed_at desc
limit 50;
```

Restore a deleted memory (use the `id` of the history row):

```sql
insert into public.memories
select * from jsonb_populate_record(null::public.memories, (select row_data from public.row_history where id = 123));
```

Undo an edit (put the old version of a memory back):

```sql
update public.memories m
set date = r.date, text = r.text, media = r.media, tags = r.tags, favorite = r.favorite,
    sticker = r.sticker, place = r.place, lat = r.lat, lng = r.lng, unlock_date = r.unlock_date, song = r.song
from jsonb_populate_record(null::public.memories, (select row_data from public.row_history where id = 123)) r
where m.id = r.id;
```

## Good habits

- Keep each migration file as it was run; add a new numbered one for every change.
- Never put the `service_role` / secret key in any site file. Only the publishable key belongs in `config.js`.
- Free Supabase projects don't keep automatic downloadable backups, so the in-app backup is your safety copy. Keep a few.
