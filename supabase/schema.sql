-- Ada Azul - esquema base sanitizado
-- No contiene usuarios administradores, cuentas bancarias ni secretos.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,full_name)
  values(new.id,coalesce(new.raw_user_meta_data->>'full_name',''))
  on conflict(id) do nothing;
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.profiles where id=auth.uid() and role='admin');
$$;

create table if not exists public.user_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  housing_type text check (housing_type in ('apartment','house_no_yard','house_with_yard')),
  has_yard boolean not null default false,
  daily_available_minutes integer check (daily_available_minutes between 0 and 1440),
  enjoys_walks boolean not null default false,
  activity_level text check (activity_level in ('low','medium','high')),
  has_dogs boolean not null default false,
  has_cats boolean not null default false,
  has_children boolean not null default false,
  preferred_size text check (preferred_size in ('small','medium','large','any')),
  completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.dogs (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sex text not null check (sex in ('male','female')),
  size text not null check (size in ('small','medium','large')),
  age_years numeric(4,1) check (age_years >= 0),
  energy_level text not null check (energy_level in ('low','medium','high')),
  min_daily_minutes integer not null default 30 check (min_daily_minutes >= 0),
  description text,
  location text,
  good_with_dogs boolean,
  good_with_cats boolean,
  good_with_children boolean,
  sterilized boolean,
  vaccinated boolean,
  status text not null default 'available' check (status in ('available','in_process','adopted','hidden')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.dog_photos (
  id uuid primary key default gen_random_uuid(),
  dog_id uuid not null references public.dogs(id) on delete cascade,
  image_url text not null,
  is_primary boolean not null default false,
  display_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.interests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  dog_id uuid not null references public.dogs(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(user_id,dog_id)
);

create table if not exists public.adoption_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  dog_id uuid not null references public.dogs(id),
  motivation text,
  housing_details text,
  experience text,
  comments text,
  contact_phone text,
  status text not null default 'pending' check (status in ('pending','reviewing','approved','rejected','cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  starts_at timestamptz not null,
  ends_at timestamptz,
  location text,
  event_type text,
  status text not null default 'active' check (status in ('active','cancelled','finished')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint valid_event_dates check (ends_at is null or ends_at >= starts_at)
);

create table if not exists public.donation_methods (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('bank_transfer','paypal','in_kind')),
  title text not null,
  description text,
  account_holder text,
  bank_name text,
  account_number text,
  clabe text,
  paypal_url text,
  instructions text,
  is_active boolean not null default false,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.shelter_settings (
  id integer primary key default 1,
  name text not null default 'Ada Azul Albergue',
  address text, phone text, whatsapp text, email text, facebook text,
  instagram text, website text, opening_hours text,
  updated_at timestamptz not null default now(),
  constraint one_shelter_only check(id=1)
);

alter table public.profiles enable row level security;
alter table public.user_preferences enable row level security;
alter table public.dogs enable row level security;
alter table public.dog_photos enable row level security;
alter table public.interests enable row level security;
alter table public.adoption_applications enable row level security;
alter table public.events enable row level security;
alter table public.donation_methods enable row level security;
alter table public.shelter_settings enable row level security;

-- Policies are intentionally named and recreated explicitly in your live project.
-- Keep the live RLS rules in Supabase as the source of truth before applying this file.

-- Minimum client privileges. RLS still controls which rows are accessible.
grant usage on schema public to authenticated;
grant select on public.profiles to authenticated;
grant select,insert,update on public.user_preferences to authenticated;
grant select,insert,update,delete on public.dogs to authenticated;
grant select,insert,update,delete on public.dog_photos to authenticated;
grant select,insert,update,delete on public.interests to authenticated;
grant select,insert,update on public.adoption_applications to authenticated;
grant select,insert,update,delete on public.events to authenticated;
grant select,insert,update,delete on public.donation_methods to authenticated;
grant select,update on public.shelter_settings to authenticated;
grant execute on function public.is_admin() to authenticated;
