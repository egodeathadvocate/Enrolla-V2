# Enrolla architecture

## Runtime

`index.html` remains the only application file. It uses vanilla JavaScript, internal
CSS, Google Fonts/Material Symbols, and the pinned Supabase JS v2 CDN. With placeholder
configuration it uses localStorage Demo Mode. With real Supabase values it uses Auth,
Postgres, RLS, and Realtime.

## Tables

| Table | Purpose |
|---|---|
| `profiles` | Auth-linked identity, student ID, program/year, enrollment status, and role |
| `programs` | Academic programs and assigned subject codes |
| `courses` | Catalog subjects, schedules, rooms, instructors, capacity, and topics |
| `enrollments` | Student/course status transitions and submission dates |
| `enrollment_settings` | Enrollment mode, dates, academic year, and semester |
| `special_requests` | Late enrollment, overload, conflict, full-subject, and drop requests |
| `audit_logs` | Administrative actions and security history |
| `notifications` | Per-profile notification bell items |
| `student_profile_data` | Extended student profile and medical-clearance fields |

`auth.users` is owned by Supabase Auth. A signup trigger creates a `profiles` row with
role `student`; the browser cannot select its own role. `email_for_login()` supports
the existing student-ID login experience without returning passwords or other records.

## RLS summary

- Authenticated students can read courses, programs, and enrollment settings.
- Students can read/write only their own profile-owned enrollments, requests,
  notifications, and profile data.
- Admins can manage catalog, settings, student records, enrollments, requests, and
  notifications, and can read/insert audit logs.
- Only `super_admin` can change profile roles. The database trigger blocks role changes
  by ordinary admins and students.
- `is_admin()` and `is_super_admin()` are `SECURITY DEFINER` helpers with a fixed
  `search_path`; UI guards are not security controls.

## Realtime channel map

After authentication, the client subscribes to `postgres_changes` on:

`profiles`, `programs`, `courses`, `enrollments`, `special_requests`,
`notifications`, `enrollment_settings`, and `audit_logs`.

Events trigger a fresh RLS-filtered query and a focused re-render. Channels are removed
on logout. Connection failures show a Reconnecting indicator and refetch when the
channel recovers. The migration adds the tables to `supabase_realtime` and uses full
replica identity for update/delete reconciliation.

## Deployment

GitHub Pages builds the root `index.html` into a static artifact. Supabase migrations
are run manually in SQL Editor or with the CLI; the optional manual GitHub Actions
workflow uses repository secrets and never stores them in source.
