create table public.suppliers (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    supplier_code text not null,

    supplier_name text not null,

    contact_name text,

    email text,

    phone text,

    address text,

    status text not null default 'ACTIVE'
        check (status in ('ACTIVE', 'INACTIVE', 'BLOCKED')),

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint suppliers_name_not_blank
        check (btrim(supplier_name) <> ''),

    constraint suppliers_code_not_blank
        check (btrim(supplier_code) <> ''),

    constraint suppliers_organization_code_unique
        unique (organization_id, supplier_code)
);

create trigger set_suppliers_updated_at
before update on public.suppliers
for each row
execute function public.set_updated_at();

alter table public.suppliers
enable row level security;

create index suppliers_organization_name_idx
on public.suppliers (organization_id, lower(supplier_name));

alter table public.suppliers
add constraint suppliers_id_organization_unique
unique (id, organization_id);