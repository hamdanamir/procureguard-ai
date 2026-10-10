create extension if not exists btree_gist;


create table public.supplier_products (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    supplier_id uuid not null,

    product_id uuid not null,

    supplier_sku text,

    agreed_unit_price numeric(14,2) not null
        check (agreed_unit_price > 0),

    currency text not null default 'PKR'
        check (currency ~ '^[A-Z]{3}$'),

    tolerance_percent numeric(5,2) not null default 2.00
        check (
            tolerance_percent >= 0
            and tolerance_percent <= 100
        ),

    effective_from date not null,

    effective_to date,

    status text not null default 'ACTIVE'
        check (
            status in ('ACTIVE', 'INACTIVE', 'CANCELLED')
        ),

    notes text,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint supplier_products_supplier_organization_fk
        foreign key (supplier_id, organization_id)
        references public.suppliers(id, organization_id)
        on delete restrict,

    constraint supplier_products_product_organization_fk
        foreign key (product_id, organization_id)
        references public.products(id, organization_id)
        on delete restrict,

    constraint supplier_products_sku_not_blank
        check (
            supplier_sku is null
            or btrim(supplier_sku) <> ''
        ),

    constraint supplier_products_effective_dates_valid
        check (
            effective_to is null
            or effective_to >= effective_from
        ),

    constraint supplier_products_no_overlapping_active_agreements
        exclude using gist (
            supplier_id with =,
            product_id with =,
            daterange(
                effective_from,
                coalesce(effective_to + 1, 'infinity'::date),
                '[)'
            ) with &&
        )
        where (status = 'ACTIVE')
);

create trigger set_supplier_products_updated_at
before update on public.supplier_products
for each row
execute function public.set_updated_at();

alter table public.supplier_products
enable row level security;

create index supplier_products_lookup_idx
on public.supplier_products (
    organization_id,
    supplier_id,
    product_id,
    effective_from
);