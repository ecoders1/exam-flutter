-- ============================================================
-- Exit Exam Ethiopia — Supabase Database Schema
-- IDEMPOTENT: safe to run multiple times
-- ============================================================

create extension if not exists "uuid-ossp";

-- ── TABLES ────────────────────────────────────────────────────────────────────

create table if not exists public.users (
  id                    uuid primary key references auth.users(id) on delete cascade,
  full_name             text not null,
  email                 text not null unique,
  avatar_url            text,
  device_id             text,
  is_admin              boolean default false,
  is_blocked            boolean default false,
  unlocked_departments  text[] default '{}',
  created_at            timestamptz default now()
);

create table if not exists public.device_sessions (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid references public.users(id) on delete cascade,
  device_id   text not null unique,
  last_seen   timestamptz default now(),
  created_at  timestamptz default now()
);

create table if not exists public.departments (
  id           uuid primary key default uuid_generate_v4(),
  name         text not null,
  year         text not null,
  description  text,
  icon_url     text,
  price        numeric(10,2) default 200.00,
  is_default   boolean default false,
  is_active    boolean default true,
  exam_count   integer default 0,
  created_at   timestamptz default now()
);

create table if not exists public.exams (
  id                uuid primary key default uuid_generate_v4(),
  title             text not null,
  department_id     uuid references public.departments(id) on delete cascade,
  description       text,
  question_count    integer default 0,
  duration_minutes  integer default 60,
  pass_mark_percent numeric(5,2) default 50.00,
  is_published      boolean default false,
  source_file_url   text,
  source_file_type  text,
  created_at        timestamptz default now()
);

create table if not exists public.questions (
  id              uuid primary key default uuid_generate_v4(),
  exam_id         uuid references public.exams(id) on delete cascade,
  question_text   text not null,
  option_a        text not null,
  option_b        text not null,
  option_c        text not null,
  option_d        text not null,
  correct_option  char(1) not null check (correct_option in ('A','B','C','D')),
  explanation     text,
  image_url       text,
  order_index     integer default 0,
  created_at      timestamptz default now()
);

create table if not exists public.results (
  id                  uuid primary key default uuid_generate_v4(),
  user_id             uuid references public.users(id) on delete cascade,
  exam_id             uuid references public.exams(id) on delete cascade,
  total_questions     integer not null,
  correct_answers     integer not null,
  wrong_answers       integer not null,
  score_percent       numeric(5,2) not null,
  passed              boolean not null,
  time_used_seconds   integer not null,
  answers             jsonb default '{}',
  completed_at        timestamptz default now()
);

create table if not exists public.payments (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid references public.users(id) on delete cascade,
  department_id   uuid references public.departments(id) on delete cascade,
  amount          numeric(10,2) not null,
  method          text not null,
  screenshot_url  text,
  status          text default 'pending' check (status in ('pending','approved','rejected')),
  admin_note      text,
  approved_at     timestamptz,
  created_at      timestamptz default now()
);

create table if not exists public.uploads (
  id           uuid primary key default uuid_generate_v4(),
  exam_id      uuid references public.exams(id) on delete cascade,
  file_name    text not null,
  file_url     text,
  file_type    text,
  uploaded_by  uuid references public.users(id),
  created_at   timestamptz default now()
);

create table if not exists public.admin_logs (
  id          uuid primary key default uuid_generate_v4(),
  admin_id    uuid references public.users(id),
  action      text not null,
  target_id   text,
  note        text,
  created_at  timestamptz default now()
);

-- ── SEED DEFAULT DEPARTMENTS ──────────────────────────────────────────────────

insert into public.departments (name, year, price, is_default, is_active)
values
  ('Ethiopian Exit Exam 2015', '2015', 0,   true,  true),
  ('Ethiopian Exit Exam 2016', '2016', 200, false, true),
  ('Ethiopian Exit Exam 2017', '2017', 200, false, true),
  ('Ethiopian Exit Exam 2018', '2018', 200, false, true)
on conflict do nothing;

-- ── ENABLE RLS ────────────────────────────────────────────────────────────────

alter table public.users             enable row level security;
alter table public.device_sessions   enable row level security;
alter table public.departments       enable row level security;
alter table public.exams             enable row level security;
alter table public.questions         enable row level security;
alter table public.results           enable row level security;
alter table public.payments          enable row level security;
alter table public.uploads           enable row level security;
alter table public.admin_logs        enable row level security;

-- ── DROP ALL EXISTING POLICIES (idempotent) ───────────────────────────────────

drop policy if exists "Users can read own profile"           on public.users;
drop policy if exists "Users can update own profile"         on public.users;
drop policy if exists "Users can insert own profile"         on public.users;
drop policy if exists "Admin can read all users"             on public.users;
drop policy if exists "Admin can update all users"           on public.users;

drop policy if exists "Anyone can read active departments"   on public.departments;
drop policy if exists "Admin can manage departments"         on public.departments;

drop policy if exists "Anyone can read published exams"      on public.exams;
drop policy if exists "Admin can manage exams"               on public.exams;

drop policy if exists "Authenticated users can read questions" on public.questions;
drop policy if exists "Admin can manage questions"           on public.questions;

drop policy if exists "Users can read own results"           on public.results;
drop policy if exists "Users can insert own results"         on public.results;
drop policy if exists "Admin can read all results"           on public.results;

drop policy if exists "Users can read own payments"          on public.payments;
drop policy if exists "Users can insert own payments"        on public.payments;
drop policy if exists "Admin can manage all payments"        on public.payments;

drop policy if exists "Users can manage own device sessions" on public.device_sessions;

drop policy if exists "Admin can manage uploads"             on public.uploads;
drop policy if exists "Admin can manage logs"                on public.admin_logs;

-- ── CREATE POLICIES ───────────────────────────────────────────────────────────

-- users
create policy "Users can read own profile"
  on public.users for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.users for update
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.users for insert
  with check (auth.uid() = id);

create policy "Admin can read all users"
  on public.users for select
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

create policy "Admin can update all users"
  on public.users for update
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

-- departments
create policy "Anyone can read active departments"
  on public.departments for select
  using (is_active = true);

create policy "Admin can manage departments"
  on public.departments for all
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

-- exams
create policy "Anyone can read published exams"
  on public.exams for select
  using (is_published = true);

create policy "Admin can manage exams"
  on public.exams for all
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

-- questions
create policy "Authenticated users can read questions"
  on public.questions for select
  using (auth.role() = 'authenticated');

create policy "Admin can manage questions"
  on public.questions for all
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

-- results
create policy "Users can read own results"
  on public.results for select
  using (auth.uid() = user_id);

create policy "Users can insert own results"
  on public.results for insert
  with check (auth.uid() = user_id);

create policy "Admin can read all results"
  on public.results for select
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

-- payments
create policy "Users can read own payments"
  on public.payments for select
  using (auth.uid() = user_id);

create policy "Users can insert own payments"
  on public.payments for insert
  with check (auth.uid() = user_id);

create policy "Admin can manage all payments"
  on public.payments for all
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

-- device_sessions
create policy "Users can manage own device sessions"
  on public.device_sessions for all
  using (auth.uid() = user_id);

-- uploads
create policy "Admin can manage uploads"
  on public.uploads for all
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

-- admin_logs
create policy "Admin can manage logs"
  on public.admin_logs for all
  using (
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

-- ── STORAGE BUCKETS ───────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('uploads', 'uploads', false)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('payments', 'payments', false)
on conflict (id) do nothing;

-- Storage policies (drop first)
drop policy if exists "Admin can upload files"                on storage.objects;
drop policy if exists "Users can upload payment screenshots"  on storage.objects;
drop policy if exists "Admin can read payment screenshots"    on storage.objects;
drop policy if exists "Users can read own payment screenshots" on storage.objects;

create policy "Admin can upload files"
  on storage.objects for insert
  with check (
    bucket_id = 'uploads' and
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

create policy "Users can upload payment screenshots"
  on storage.objects for insert
  with check (
    bucket_id = 'payments' and
    auth.role() = 'authenticated'
  );

create policy "Admin can read payment screenshots"
  on storage.objects for select
  using (
    bucket_id = 'payments' and
    exists (select 1 from public.users u where u.id = auth.uid() and u.is_admin = true)
  );

create policy "Users can read own payment screenshots"
  on storage.objects for select
  using (
    bucket_id = 'payments' and
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- ── SET ADMIN USER ────────────────────────────────────────────────────────────
-- Run this AFTER your first signup with milkiyaas43@gmail.com:
--
-- update public.users set is_admin = true where email = 'milkiyaas43@gmail.com';
