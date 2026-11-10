# Enrolla repository instructions

- Keep the app usable in demo mode: it is a single `index.html` frontend and currently
  persists demo data in browser `localStorage`.
- Do not commit credentials, tokens, private keys, or Supabase `service_role` values.
  Browser code may use only the public `anon` key with Row Level Security enabled.
- Do not edit SQL schema/migration files as part of frontend or repository setup work.
- Keep authentication, authorization, enrollment, and drop-request decisions server-side
  when Supabase mode is introduced; never trust a role supplied by the browser.
- Preserve realtime subscriptions for enrollment/request changes and unsubscribe them
  when a view is destroyed.
- Prefer small, accessible, responsive changes. Validate with `npm run build` and inspect
  the app in a local browser before submitting.
