-- Run this script in the Supabase SQL Editor for the project used by index.html.
-- Then create your account in the website and run the administrator bootstrap
-- statement at the end of this file with your account email.

create table if not exists public.universities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text not null,
  country text not null default 'Germany',
  description text not null,
  programs text not null default '',
  tuition text not null default '',
  deadline text not null default '',
  official_url text not null,
  application_url text not null default '',
  created_at timestamptz not null default now(),
  constraint universities_name_city_unique unique (name, city)
);

create table if not exists public.university_admins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.universities enable row level security;
alter table public.university_admins enable row level security;

create or replace function public.is_university_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.university_admins as admins
    where admins.user_id = auth.uid()
  );
$$;

revoke all on function public.is_university_admin() from public;
grant execute on function public.is_university_admin() to authenticated;

create or replace function public.search_universities(search_term text default '')
returns setof public.universities
language sql
stable
as $$
  select university.*
  from public.universities as university
  where nullif(btrim(coalesce(search_term, '')), '') is null
    or concat_ws(
      ' ',
      university.name,
      university.city,
      university.country,
      university.programs,
      university.description
    ) ilike '%' || left(btrim(coalesce(search_term, '')), 120) || '%'
  order by university.name, university.city;
$$;

revoke all on function public.search_universities(text) from public;
grant execute on function public.search_universities(text) to authenticated;
revoke all on public.universities from anon, public;
revoke all on public.university_admins from anon, public;
grant select, insert, update, delete on public.universities to authenticated;
grant select, insert, delete on public.university_admins to authenticated;

drop policy if exists "Signed-in users can view universities" on public.universities;
create policy "Signed-in users can view universities"
  on public.universities for select to authenticated
  using (auth.uid() is not null);

drop policy if exists "Admins can add universities" on public.universities;
create policy "Admins can add universities"
  on public.universities for insert to authenticated
  with check (public.is_university_admin());

drop policy if exists "Admins can update universities" on public.universities;
create policy "Admins can update universities"
  on public.universities for update to authenticated
  using (public.is_university_admin())
  with check (public.is_university_admin());

drop policy if exists "Admins can delete universities" on public.universities;
create policy "Admins can delete universities"
  on public.universities for delete to authenticated
  using (public.is_university_admin());

drop policy if exists "Users can view their own admin status" on public.university_admins;
create policy "Users can view their own admin status"
  on public.university_admins for select to authenticated
  using (user_id = auth.uid() or public.is_university_admin());

drop policy if exists "Admins can add administrators" on public.university_admins;
create policy "Admins can add administrators"
  on public.university_admins for insert to authenticated
  with check (public.is_university_admin());

drop policy if exists "Admins can remove administrators" on public.university_admins;
create policy "Admins can remove administrators"
  on public.university_admins for delete to authenticated
  using (public.is_university_admin());

insert into public.universities
  (name, city, country, description, programs, tuition, deadline, official_url, application_url)
values
  (
    'RWTH Aachen University',
    'Aachen',
    'Germany',
    'Sample profile: a technical university with a broad range of engineering and science programs. Check the official university site for current course information.',
    'Engineering, natural sciences, computer science',
    'Fees and contributions vary. Verify current costs with the university.',
    'Deadlines depend on the program and applicant. Check the official program page.',
    'https://www.rwth-aachen.de/',
    'https://www.rwth-aachen.de/go/id/a/?lidx=1'
  ),
  (
    'TU Berlin',
    'Berlin',
    'Germany',
    'Sample profile: a technical university in Berlin offering programs across engineering, computing, and natural sciences.',
    'Engineering, computer science, natural sciences',
    'Fees and contributions vary. Verify current costs with the university.',
    'Deadlines depend on the program and applicant. Check the official program page.',
    'https://www.tu.berlin/',
    'https://www.tu.berlin/en/studying'
  ),
  (
    'University of Stuttgart',
    'Stuttgart',
    'Germany',
    'Sample profile: a research university with a range of technical and interdisciplinary study options.',
    'Engineering, architecture, natural sciences',
    'Fees and contributions vary. Verify current costs with the university.',
    'Deadlines depend on the program and applicant. Check the official program page.',
    'https://www.uni-stuttgart.de/en/',
    'https://www.uni-stuttgart.de/en/study/application/'
  ),
  (
    'Technical University of Munich',
    'Munich',
    'Germany',
    'Sample profile: a research university with study options in engineering, computing, natural sciences, and other fields. Check each program page for admissions requirements.',
    'Engineering, computer science, natural sciences, management',
    'Tuition and semester contributions depend on the program and applicant. Verify current costs with the university.',
    'Deadlines depend on the program and applicant. Check the official program page.',
    'https://www.tum.de/en/',
    'https://www.tum.de/en/studies'
  ),
  (
    'Karlsruhe Institute of Technology',
    'Karlsruhe',
    'Germany',
    'Sample profile: a research university with programs spanning engineering, information technology, and natural sciences.',
    'Engineering, computer science, natural sciences',
    'Fees and contributions depend on the program and applicant. Verify current costs with the university.',
    'Deadlines depend on the program and applicant. Check the official program page.',
    'https://www.kit.edu/english/',
    'https://www.kit.edu/english/study.php'
  ),
  (
    'TU Darmstadt',
    'Darmstadt',
    'Germany',
    'Sample profile: a technical university with a broad range of engineering, computing, and natural-science programs.',
    'Engineering, computer science, natural sciences, architecture',
    'Fees and semester contributions vary. Verify current costs with the university.',
    'Deadlines depend on the program and applicant. Check the official program page.',
    'https://www.tu-darmstadt.de/index.en.jsp',
    'https://www.tu-darmstadt.de/studieren/index.en.jsp'
  ),
  (
    'TU Dresden',
    'Dresden',
    'Germany',
    'Sample profile: a research university offering technical and interdisciplinary programs across multiple faculties.',
    'Engineering, computer science, natural sciences, transport',
    'Fees and semester contributions vary. Verify current costs with the university.',
    'Deadlines depend on the program and applicant. Check the official program page.',
    'https://tu-dresden.de/?set_language=en',
    'https://tu-dresden.de/studium?set_language=en'
  ),
  (
    'Leibniz University Hannover',
    'Hannover',
    'Germany',
    'Sample profile: a research university with study options in engineering, architecture, natural sciences, and related fields.',
    'Engineering, architecture, natural sciences, computer science',
    'Fees and semester contributions vary. Verify current costs with the university.',
    'Deadlines depend on the program and applicant. Check the official program page.',
    'https://www.uni-hannover.de/en/',
    'https://www.uni-hannover.de/en/studium'
  ),
  (
    'Friedrich-Alexander University Erlangen-Nürnberg',
    'Erlangen',
    'Germany',
    'Sample profile: a research university with programs in engineering, technology, natural sciences, and other disciplines.',
    'Engineering, computer science, natural sciences, medicine',
    'Fees and semester contributions vary. Verify current costs with the university.',
    'Deadlines depend on the program and applicant. Check the official program page.',
    'https://www.fau.eu/',
    'https://www.fau.eu/education/'
  )
on conflict (name, city) do nothing;

-- After creating and confirming your account, replace the email below and
-- run this statement in the SQL Editor to make your account an administrator.
-- insert into public.university_admins (user_id)
-- select id from auth.users where email = 'you@example.com'
-- on conflict (user_id) do nothing;
