-- pgTAP checks for the Enrolla RLS contract.
begin;
select plan(12);

select has_table('public', 'profiles', 'profiles table exists');
select has_table('public', 'courses', 'courses table exists');
select has_table('public', 'enrollments', 'enrollments table exists');
select has_table('public', 'special_requests', 'special_requests table exists');
select has_function('public', 'is_admin', 'is_admin helper exists');
select has_function('public', 'is_super_admin', 'is_super_admin helper exists');

select is((select count(*)::integer from pg_policies where schemaname = 'public' and tablename = 'profiles'), 3, 'profiles has explicit policies');
select is((select count(*)::integer from pg_policies where schemaname = 'public' and tablename = 'courses'), 2, 'courses has explicit policies');
select is((select count(*)::integer from pg_policies where schemaname = 'public' and tablename = 'enrollments'), 4, 'enrollments has explicit policies');
select is((select count(*)::integer from pg_policies where schemaname = 'public' and tablename = 'special_requests'), 3, 'requests have explicit policies');
select is((select count(*)::integer from pg_policies where schemaname = 'public' and tablename = 'notifications'), 3, 'notifications have explicit policies');
select is((select count(*)::integer from pg_policies where schemaname = 'public' and tablename = 'student_profile_data'), 2, 'student data has explicit policies');

select * from finish();
rollback;
