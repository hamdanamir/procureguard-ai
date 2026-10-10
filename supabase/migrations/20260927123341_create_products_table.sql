create table public.products (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    sku text not null,

    product_name text not null,

    category text,

    unit text not null,

    status text not null default 'ACTIVE'
        check (status in ('ACTIVE', 'INACTIVE', 'DISCONTINUED')),

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint products_name_not_blank
        check (btrim(product_name) <> ''),

    constraint products_sku_not_blank
        check (btrim(sku) <> ''),

    constraint products_unit_not_blank
        check (btrim(unit) <> ''),

    constraint products_organization_sku_unique
        unique (organization_id, sku)
);

create trigger set_products_updated_at
before update on public.products
for each row
execute function public.set_updated_at();

alter table public.products
enable row level security;

create index products_organization_name_idx
on public.products (organization_id, lower(product_name));

create index products_organization_status_idx
on public.products (organization_id, status);
alter table public.products
add constraint products_id_organization_unique
unique (id, organization_id);