alter table public.purchase_orders
add constraint purchase_orders_id_organization_unique
unique (id, organization_id);

create table public.purchase_order_items (
    constraint purchase_order_items_id_organization_unique
    unique (id, organization_id),
    id uuid primary key default gen_random_uuid(),

    purchase_order_id uuid not null,

    organization_id uuid not null,

    line_number integer not null
        check (line_number > 0),

    product_id uuid not null,

    description_from_po text,

    ordered_quantity numeric(14,3) not null
        check (ordered_quantity > 0),

    unit_price numeric(14,2) not null
        check (unit_price > 0),

    discount numeric(14,2) not null default 0.00
        check (discount >= 0),

    tax numeric(14,2) not null default 0.00
        check (tax >= 0),

    line_total numeric(14,2)
        generated always as (
            round(
                (ordered_quantity * unit_price)
                + tax
                - discount,
                2
            )
        ) stored,

    received_quantity numeric(14,3) not null default 0.000
        check (
            received_quantity >= 0
            and received_quantity <= ordered_quantity
        ),

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint purchase_order_items_po_organization_fk
        foreign key (purchase_order_id, organization_id)
        references public.purchase_orders(id, organization_id)
        on delete restrict,

    constraint purchase_order_items_product_organization_fk
        foreign key (product_id, organization_id)
        references public.products(id, organization_id)
        on delete restrict,

    constraint purchase_order_items_line_unique
        unique (purchase_order_id, line_number),

    constraint purchase_order_items_description_not_blank
        check (
            description_from_po is null
            or btrim(description_from_po) <> ''
        )
);

create trigger set_purchase_order_items_updated_at
before update on public.purchase_order_items
for each row
execute function public.set_updated_at();

alter table public.purchase_order_items
enable row level security;

create index purchase_order_items_po_idx
on public.purchase_order_items (
    organization_id,
    purchase_order_id,
    line_number
);

create index purchase_order_items_product_idx
on public.purchase_order_items (
    organization_id,
    product_id
);