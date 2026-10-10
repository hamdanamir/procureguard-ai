create table public.product_aliases (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    supplier_id uuid not null,

    product_id uuid not null,

    alias_name text not null,

    normalized_alias text
        generated always as (
            lower(btrim(alias_name))
        ) stored,

    match_source text not null
        check (
            match_source in (
                'AI',
                'HUMAN_VERIFIED',
                'IMPORTED'
            )
        ),

    confidence_score numeric(4,3) not null default 1.000
        check (
            confidence_score >= 0
            and confidence_score <= 1
        ),

    status text not null default 'PENDING_REVIEW'
        check (
            status in (
                'ACTIVE',
                'PENDING_REVIEW',
                'DISABLED'
            )
        ),

    notes text,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint product_aliases_supplier_organization_fk
        foreign key (supplier_id, organization_id)
        references public.suppliers(id, organization_id)
        on delete restrict,

    constraint product_aliases_product_organization_fk
        foreign key (product_id, organization_id)
        references public.products(id, organization_id)
        on delete restrict,

    constraint product_aliases_name_not_blank
        check (btrim(alias_name) <> ''),

    constraint product_aliases_supplier_alias_unique
        unique (supplier_id, normalized_alias)
);

create trigger set_product_aliases_updated_at
before update on public.product_aliases
for each row
execute function public.set_updated_at();

alter table public.product_aliases
enable row level security;

create index product_aliases_lookup_idx
on public.product_aliases (
    organization_id,
    supplier_id,
    normalized_alias
);