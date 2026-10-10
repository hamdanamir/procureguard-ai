create table public.organizations (
    id uuid primary key default gen_random_uuid(),

    name text not null,

    email text,

    phone text,

    status text not null default 'ACTIVE'
        check (status in ('ACTIVE', 'INACTIVE')),

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint organizations_name_not_blank
        check (btrim(name) <> '')
); 
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;
create trigger set_organizations_updated_at
before update on public.organizations
for each row
execute function public.set_updated_at();
alter table public.organizations enable row level security;