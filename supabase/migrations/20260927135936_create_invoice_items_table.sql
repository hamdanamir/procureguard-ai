create table public.invoice_items (
    id uuid primary key default gen_random_uuid(),

    invoice_id uuid not null,

    organization_id uuid not null,

    line_number integer not null
        check (line_number > 0),

    product_id uuid not null,

    purchase_order_item_id uuid,

    description_from_invoice text,

    supplier_sku text,

    invoiced_quantity numeric(14,3) not null
        check (invoiced_quantity > 0),

    unit_price numeric(14,2) not null
        check (unit_price > 0),

    discount numeric(14,2) not null default 0.00
        check (discount >= 0),

    tax numeric(14,2) not null default 0.00
        check (tax >= 0),

    line_total numeric(14,2)
        generated always as (
            round(
                (invoiced_quantity * unit_price)
                + tax
                - discount,
                2
            )
        ) stored,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint invoice_items_id_organization_unique
        unique (id, organization_id),

    constraint invoice_items_invoice_organization_fk
        foreign key (invoice_id, organization_id)
        references public.invoices(id, organization_id)
        on delete restrict,

    constraint invoice_items_product_organization_fk
        foreign key (product_id, organization_id)
        references public.products(id, organization_id)
        on delete restrict,

    constraint invoice_items_po_item_organization_fk
        foreign key (purchase_order_item_id, organization_id)
        references public.purchase_order_items(id, organization_id)
        on delete restrict,

    constraint invoice_items_line_unique
        unique (invoice_id, line_number),

    constraint invoice_items_description_not_blank
        check (
            description_from_invoice is null
            or btrim(description_from_invoice) <> ''
        ),

    constraint invoice_items_supplier_sku_not_blank
        check (
            supplier_sku is null
            or btrim(supplier_sku) <> ''
        )
);

create trigger set_invoice_items_updated_at
before update on public.invoice_items
for each row
execute function public.set_updated_at();

alter table public.invoice_items
enable row level security;

create index invoice_items_invoice_idx
on public.invoice_items (
    organization_id,
    invoice_id,
    line_number
);

create index invoice_items_product_idx
on public.invoice_items (
    organization_id,
    product_id
);

create index invoice_items_po_item_idx
on public.invoice_items (
    organization_id,
    purchase_order_item_id
);