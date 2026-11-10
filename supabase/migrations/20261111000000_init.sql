-- Enrolla relational schema. Safe to run once through Supabase migrations.
create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.programs (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[A-Z0-9]+$'),
  name text not null,
  department text not null,
  description text not null default '',
  subject_codes text[] not null default '{}',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  student_id text unique,
  username text unique,
  full_name text not null,
  email text,
  contact text,
  program_code text references public.programs(code) on update cascade on delete set null,
  year_level text,
  enrollment_status text not null default 'Not Enrolled'
    check (enrollment_status in ('Enrolled','Pending','Not Enrolled','Irregular')),
  role text not null default 'student'
    check (role in ('student','admin','super_admin')),
  is_demo boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists profiles_student_id_idx on public.profiles(student_id) where student_id is not null;
create index if not exists profiles_program_code_idx on public.profiles(program_code);

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  title text not null,
  description text not null default '',
  instructor text not null,
  building text,
  room text,
  schedule_text text not null,
  units integer not null check (units between 1 and 12),
  program_code text references public.programs(code) on update cascade on delete set null,
  max_capacity integer not null check (max_capacity > 0),
  enrolled_count integer not null default 0 check (enrolled_count >= 0 and enrolled_count <= max_capacity),
  status text not null default 'available' check (status in ('available','enrolled','closed')),
  course_type text not null default 'Core',
  days text[] not null default '{}',
  start_hour numeric(4,2) not null default 0 check (start_hour between 0 and 24),
  duration numeric(4,2) not null default 1 check (duration > 0 and duration <= 24),
  color text,
  prerequisite text,
  topics text[] not null default '{}',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists courses_program_code_idx on public.courses(program_code);
create index if not exists courses_status_idx on public.courses(status);

create table if not exists public.enrollments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete restrict,
  program_code text references public.programs(code) on update cascade on delete set null,
  status text not null default 'Pending'
    check (status in ('Pending','Approved','Rejected','Cancelled')),
  date_submitted timestamptz not null default timezone('utc', now()),
  decided_at timestamptz,
  decided_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (student_id, course_id)
);

create index if not exists enrollments_student_idx on public.enrollments(student_id);
create index if not exists enrollments_course_idx on public.enrollments(course_id);
create index if not exists enrollments_status_idx on public.enrollments(status);

create table if not exists public.enrollment_settings (
  id integer primary key default 1 check (id = 1),
  mode text not null default 'manual' check (mode in ('manual','automatic')),
  manual_status text not null default 'Open' check (manual_status in ('Open','Closed')),
  start_date_time timestamptz,
  end_date_time timestamptz,
  academic_year text not null default '2026 - 2027',
  semester text not null default '1st Semester (Fall)',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.special_requests (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  type text not null check (type in ('Unit Overload','Full Subject Override','Late Enrollment','Subject Drop Request')),
  course_id uuid references public.courses(id) on delete set null,
  units integer check (units is null or units > 0),
  reason text not null,
  status text not null default 'Pending' check (status in ('Pending','Approved','Rejected')),
  admin_remark text not null default '',
  decided_by uuid references public.profiles(id) on delete set null,
  date_submitted timestamptz not null default timezone('utc', now()),
  decided_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists special_requests_student_idx on public.special_requests(student_id);
create index if not exists special_requests_status_idx on public.special_requests(status);

create table if not exists public.audit_logs (
  id bigint generated by default as identity primary key,
  actor_id uuid references public.profiles(id) on delete set null,
  actor text not null,
  role text,
  module text not null,
  action text not null,
  details text not null default '',
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists audit_logs_created_at_idx on public.audit_logs(created_at desc);
create index if not exists audit_logs_actor_idx on public.audit_logs(actor_id);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  icon text not null default 'info',
  text text not null,
  target text,
  unread boolean not null default true,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists notifications_profile_idx on public.notifications(profile_id, created_at desc);

create table if not exists public.student_profile_data (
  profile_id uuid primary key references public.profiles(id) on delete cascade,
  first_name text,
  middle_name text,
  last_name text,
  phone text,
  date_of_birth date,
  campus text,
  address text,
  guardian text,
  avatar_url text,
  medical_cleared boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

do $$
declare
  t text;
begin
  foreach t in array array['programs','profiles','courses','enrollments','enrollment_settings','special_requests','notifications','student_profile_data'] loop
    execute format('drop trigger if exists set_%I_updated_at on public.%I', t, t);
    execute format('create trigger set_%I_updated_at before update on public.%I for each row execute function public.set_updated_at()', t, t);
  end loop;
end $$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role in ('admin','super_admin') and is_active);
$$;

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'super_admin' and is_active);
$$;

create or replace function public.email_for_login(identifier text)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select email from public.profiles
  where lower(email) = lower(identifier) or student_id = identifier or lower(username) = lower(identifier)
  limit 1;
$$;
revoke all on function public.email_for_login(text) from public;
grant execute on function public.email_for_login(text) to anon, authenticated;

create or replace function public.prevent_client_role_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role is distinct from old.role
     and coalesce(auth.role(), '') <> 'service_role'
     and session_user not in ('postgres', 'supabase_admin')
     and not public.is_super_admin() then
    raise exception 'Only a super administrator can change profile roles';
  end if;
  return new;
end;
$$;
drop trigger if exists protect_profile_role on public.profiles;
create trigger protect_profile_role before update on public.profiles
for each row execute function public.prevent_client_role_change();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, student_id, username, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(coalesce(new.email, 'Student'), '@', 1)),
    new.raw_user_meta_data->>'student_id',
    new.raw_user_meta_data->>'username',
    'student'
  )
  on conflict (id) do update set email = excluded.email;
  insert into public.student_profile_data (profile_id, phone, avatar_url)
  values (new.id, new.raw_user_meta_data->>'contact', nullif(new.raw_user_meta_data->>'avatar_url', ''))
  on conflict (profile_id) do update
    set phone = coalesce(excluded.phone, student_profile_data.phone),
        avatar_url = coalesce(excluded.avatar_url, student_profile_data.avatar_url);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

alter table public.programs enable row level security;
alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.enrollments enable row level security;
alter table public.enrollment_settings enable row level security;
alter table public.special_requests enable row level security;
alter table public.audit_logs enable row level security;
alter table public.notifications enable row level security;
alter table public.student_profile_data enable row level security;

drop policy if exists programs_read on public.programs;
create policy programs_read on public.programs for select to authenticated using (true);
drop policy if exists programs_admin_write on public.programs;
create policy programs_admin_write on public.programs for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists profiles_self_read on public.profiles;
create policy profiles_self_read on public.profiles for select to authenticated using (id = auth.uid() or public.is_admin());
drop policy if exists profiles_self_update on public.profiles;
create policy profiles_self_update on public.profiles for update to authenticated
  using (id = auth.uid() or public.is_admin())
  with check ((id = auth.uid() and role = 'student') or public.is_admin());
drop policy if exists profiles_admin_insert on public.profiles;
create policy profiles_admin_insert on public.profiles for insert to authenticated with check (public.is_super_admin() or (id = auth.uid() and role = 'student'));
drop policy if exists profiles_super_admin_delete on public.profiles;
create policy profiles_super_admin_delete on public.profiles for delete to authenticated using (public.is_super_admin());

drop policy if exists courses_read on public.courses;
create policy courses_read on public.courses for select to authenticated using (true);
drop policy if exists courses_admin_write on public.courses;
create policy courses_admin_write on public.courses for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists enrollments_read on public.enrollments;
create policy enrollments_read on public.enrollments for select to authenticated using (student_id = auth.uid() or public.is_admin());
drop policy if exists enrollments_student_insert on public.enrollments;
create policy enrollments_student_insert on public.enrollments for insert to authenticated with check (student_id = auth.uid());
drop policy if exists enrollments_student_update on public.enrollments;
create policy enrollments_student_update on public.enrollments for update to authenticated using (student_id = auth.uid() or public.is_admin()) with check (student_id = auth.uid() or public.is_admin());
drop policy if exists enrollments_admin_delete on public.enrollments;
create policy enrollments_admin_delete on public.enrollments for delete to authenticated using (public.is_admin());

drop policy if exists settings_read on public.enrollment_settings;
create policy settings_read on public.enrollment_settings for select to authenticated using (true);
drop policy if exists settings_admin_write on public.enrollment_settings;
create policy settings_admin_write on public.enrollment_settings for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists requests_read on public.special_requests;
create policy requests_read on public.special_requests for select to authenticated using (student_id = auth.uid() or public.is_admin());
drop policy if exists requests_student_insert on public.special_requests;
create policy requests_student_insert on public.special_requests for insert to authenticated with check (student_id = auth.uid());
drop policy if exists requests_admin_update on public.special_requests;
create policy requests_admin_update on public.special_requests for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists requests_admin_delete on public.special_requests;
create policy requests_admin_delete on public.special_requests for delete to authenticated using (public.is_admin());

drop policy if exists audit_admin_read on public.audit_logs;
create policy audit_admin_read on public.audit_logs for select to authenticated using (public.is_admin());
drop policy if exists audit_admin_insert on public.audit_logs;
create policy audit_admin_insert on public.audit_logs for insert to authenticated with check (public.is_admin() or actor_id = auth.uid());

drop policy if exists notifications_self_read on public.notifications;
create policy notifications_self_read on public.notifications for select to authenticated using (profile_id = auth.uid() or public.is_admin());
drop policy if exists notifications_self_update on public.notifications;
create policy notifications_self_update on public.notifications for update to authenticated using (profile_id = auth.uid() or public.is_admin()) with check (profile_id = auth.uid() or public.is_admin());
drop policy if exists notifications_admin_insert on public.notifications;
create policy notifications_admin_insert on public.notifications for insert to authenticated with check (public.is_admin() or profile_id = auth.uid());
drop policy if exists notifications_admin_delete on public.notifications;
create policy notifications_admin_delete on public.notifications for delete to authenticated using (public.is_admin() or profile_id = auth.uid());

drop policy if exists student_data_read on public.student_profile_data;
create policy student_data_read on public.student_profile_data for select to authenticated using (profile_id = auth.uid() or public.is_admin());
drop policy if exists student_data_write on public.student_profile_data;
create policy student_data_write on public.student_profile_data for all to authenticated using (profile_id = auth.uid() or public.is_admin()) with check (profile_id = auth.uid() or public.is_admin());

do $$
declare
  t text;
begin
  foreach t in array array['profiles','programs','courses','enrollments','enrollment_settings','special_requests','notifications','student_profile_data','audit_logs'] loop
    begin
      execute format('alter publication supabase_realtime add table public.%I', t);
    exception when duplicate_object then null;
    end;
    execute format('alter table public.%I replica identity full', t);
  end loop;
end $$;
