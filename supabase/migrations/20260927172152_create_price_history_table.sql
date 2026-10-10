create table public.price_history (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    supplier_id uuid not null,

    product_id uuid not null,

    unit_price numeric(14,2) not null
        check (unit_price > 0),

    currency text not null default 'PKR'
        check (currency ~ '^[A-Z]{3}$'),

    price_type text not null
        check (
            price_type in (
                'AGREED',
                'INVOICED',
                'MANUAL'
            )
        ),

    effective_from date not null,

    effective_to date,

    source_reference text,

    notes text,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint price_history_supplier_organization_fk
        foreign key (supplier_id, organization_id)
        references public.suppliers(id, organization_id)
        on delete restrict,

    constraint price_history_product_organization_fk
        foreign key (product_id, organization_id)
        references public.products(id, organization_id)
        on delete restrict,

    constraint price_history_effective_dates_valid
        check (
            effective_to is null
            or effective_to >= effective_from
        )
);

create trigger set_price_history_updated_at
before update on public.price_history
for each row
execute function public.set_updated_at();

alter table public.price_history
enable row level security;

create index price_history_lookup_idx
on public.price_history (
    organization_id,
    supplier_id,
    product_id,
    effective_from desc
);

create index price_history_type_date_idx
on public.price_history (
    organization_id,
    price_type,
    effective_from desc
);