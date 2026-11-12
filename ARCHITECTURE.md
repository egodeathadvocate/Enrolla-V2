# Enrolla architecture

## Runtime

`index.html` remains a vanilla JavaScript frontend. The DCISM deployment uses the
same-origin PHP API in `dcism-api/`; PostgreSQL credentials and authorization stay
server-side. The frontend supports email or Student ID login through PHP sessions.
The original Supabase integration remains available only when `DCISM_MODE` is disabled.

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

For DCISM, `users` stores password hashes and `profiles` stores the application role.
`login.php`, `me.php`, and `logout.php` manage the PHP session; `state.php` returns
only the authenticated user's data (or admin data for an authorized admin).

## Authorization

PHP endpoints must enforce the equivalent ownership and role rules. UI guards are not
security controls. Write endpoints should use transactions and derive the role from
the server-side session rather than browser-supplied values.

## Updates

The PHP deployment currently loads state on login/session restore. Realtime subscriptions
from Supabase are not available on DCISM; add polling or a server push layer if live
updates are required.

## DCISM deployment

Upload `index.html` and the `dcism-api/` directory to the Dynamic Web Hosting document
root. On the server, replace `REPLACE_ON_SERVER_ONLY` in `dcism-api/db.php` with the
database password (never commit it). Run `dcism-schema.sql` and `dcism-demo-data.sql`
in Adminer before first use. Delete `db-test.php` and `php-check.php` after confirming
the host configuration, and keep HTTPS/Force TLS enabled.
