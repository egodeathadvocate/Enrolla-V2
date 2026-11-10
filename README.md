# Enrolla

![Enrolla screenshot](docs/screenshot-placeholder.png)

Enrolla is a single-file vanilla JavaScript student portal for subjects, enrollment,
schedules, special requests, notifications, and administrator review. It works
immediately in browser-only Demo Mode and can be connected to Supabase for shared
accounts and records across devices.

## Fork and set up

1. Click **Fork** on GitHub and create your copy.
2. Go to [supabase.com](https://supabase.com), click **New project**, choose the free
   plan, and wait for the database to finish provisioning.
3. In Supabase, open **SQL Editor**, create a query, paste
   `supabase/migrations/20261111000000_init.sql`, and click **Run**. Then run
   `supabase/seed.sql` if you want the public demo accounts and sample records.
4. In **Project Settings > API**, copy **Project URL** and the **anon public key** into
   the `SUPABASE_URL` and `SUPABASE_ANON_KEY` constants at the top of `index.html`.
   The anon key is intended for browser use. Never paste a service-role key.
5. In **Authentication > URL Configuration**, set **Site URL** and **Redirect URLs**
   to `https://USERNAME.github.io/REPO/`.
6. For a class demo only, you may turn off **Confirm email** under
   **Authentication > Providers > Email**. This makes sign-up immediate, but removes
   the email ownership check; turn it back on for real use.
7. Open **Settings > Pages** in GitHub, choose **GitHub Actions** as the source, and
   wait for the Pages workflow to deploy.
8. Sign up with your own account. After confirming the account, run this in Supabase
   SQL Editor to become the first administrator:

   ```sql
   update public.profiles set role = 'super_admin' where email = 'YOUR_EMAIL';
   ```

### Optional CLI setup

```bash
npm install
npm run dev
npx supabase login
npx supabase link --project-ref YOUR_PROJECT_REF
npm run db:push
```

`SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_ID`, and `SUPABASE_DB_PASSWORD` belong in
your local shell or GitHub Actions secrets, never in the repository.

## Demo accounts

Run `supabase/seed.sql` only in a disposable demo project:

- Student: `student.demo@enrolla.test` / `Demo@12345`
- Admin: `admin.demo@enrolla.test` / `Demo@12345`

Demo credentials are public. Set `ENABLE_DEMO_ACCOUNTS = false` and run
`supabase/remove-demo-data.sql` before using a project with real students.

## Demo Mode

If the Supabase placeholders remain in `index.html`, the app runs without a backend
and shows: “Demo mode: data is only saved in this browser. See README to connect a
backend.” This is useful for previewing a fresh fork, but it is not shared storage.

## How to test it

- Sign up on one device and log in on another device.
- Log in as a student and confirm only that student's profile, enrollments,
  notifications, and requests are visible.
- Try opening an admin URL or admin action as a student; RLS must reject it.
- Log in as the demo student in one window and demo admin in another.
- Submit a special request as the student and confirm it appears live in the admin
  request table.
- Approve or reject it as the admin and confirm the student's request status,
  notification bell, and enrollment view update without a refresh.
- Change a course or enrollment setting as admin and confirm another open browser
  reflects the change.

## Security notes

The anon public key is safe to embed in a static site because it identifies the
project, not a privileged database connection. Row Level Security is the real
security boundary and is enabled on every application table. Never commit a
service-role key, database password, access token, or real student credentials.
Client-side `requireAdmin()` only hides UI; database policies enforce access.

## Troubleshooting

- **Redirect URL mismatch:** use the exact GitHub Pages URL, including the trailing
  slash, under both Site URL and Redirect URLs.
- **RLS permission denied:** verify the migration ran, the user is authenticated,
  and the profile role is correct. Do not solve this by exposing a service key.
- **Email confirmation prevents login:** confirm the email or disable confirmation
  only for a disposable class demo.
- **Realtime does not fire:** confirm Realtime is enabled and the migration added the
  tables to `supabase_realtime`; reconnect after changing policies.
- **CDN/CORS blocked:** serve the repository through GitHub Pages or a local server
  (`npm run dev`), not a restricted `file://` environment.
- **Demo seed fails:** run the migration first, then run `supabase/seed.sql` in the
  same project. The seed is safe to rerun after a partial run. Its
  `auth.identities` insert uses an unqualified `ON CONFLICT` handler because
  Supabase has used different internal unique keys for that table across hosted
  versions. The seed also refreshes the role-protection function so trusted SQL
  Editor execution can update demo roles without allowing browser clients to
  change roles.

## Useful commands

```bash
npm run dev
npm run build
npm test
npm run db:start       # optional; requires Docker
npm run db:stop
npm run db:reset
npm run db:push
npm run db:test
```
