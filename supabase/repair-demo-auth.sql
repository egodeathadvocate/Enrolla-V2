-- Repair demo Auth users created by an earlier manual seed.
-- Run this once in the Supabase SQL Editor, then test sign-in again.
update auth.users
set email = coalesce(email, ''),
    phone = nullif(phone, ''),
    confirmation_token = coalesce(confirmation_token, ''),
    recovery_token = coalesce(recovery_token, ''),
    email_change = coalesce(email_change, ''),
    email_change_token_current = coalesce(email_change_token_current, ''),
    email_change_token_new = coalesce(email_change_token_new, ''),
    phone_change = coalesce(phone_change, ''),
    phone_change_token = coalesce(phone_change_token, ''),
    reauthentication_token = coalesce(reauthentication_token, ''),
    raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb),
    raw_user_meta_data = coalesce(raw_user_meta_data, '{}'::jsonb)
where email in (
  'student.demo@enrolla.test',
  'admin.demo@enrolla.test'
)
   or id in (
     '00000000-0000-0000-0000-000000000001',
     '00000000-0000-0000-0000-000000000002'
   );
