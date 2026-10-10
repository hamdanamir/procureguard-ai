create table public.purchase_orders (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    supplier_id uuid not null,

    po_number text not null,

    order_date date not null,

    expected_delivery_date date,

    currency text not null default 'PKR'
        check (currency ~ '^[A-Z]{3}$'),

    subtotal numeric(14,2) not null default 0.00
        check (subtotal >= 0),

    tax numeric(14,2) not null default 0.00
        check (tax >= 0),

    discount numeric(14,2) not null default 0.00
        check (discount >= 0),

    additional_charges numeric(14,2) not null default 0.00
        check (additional_charges >= 0),

    total numeric(14,2) not null default 0.00
        check (total >= 0),

    status text not null default 'DRAFT'
        check (
            status in (
                'DRAFT',
                'PENDING_APPROVAL',
                'APPROVED',
                'SENT',
                'PARTIALLY_RECEIVED',
                'RECEIVED',
                'CANCELLED',
                'CLOSED'
            )
        ),

    notes text,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint purchase_orders_supplier_organization_fk
        foreign key (supplier_id, organization_id)
        references public.suppliers(id, organization_id)
        on delete restrict,

    constraint purchase_orders_number_not_blank
        check (btrim(po_number) <> ''),

    constraint purchase_orders_delivery_date_valid
        check (
            expected_delivery_date is null
            or expected_delivery_date >= order_date
        ),

    constraint purchase_orders_total_consistent
        check (
            total =
            subtotal
            + tax
            + additional_charges
            - discount
        ),

    constraint purchase_orders_organization_number_unique
        unique (organization_id, po_number)
);

create trigger set_purchase_orders_updated_at
before update on public.purchase_orders
for each row
execute function public.set_updated_at();

alter table public.purchase_orders
enable row level security;

create index purchase_orders_supplier_date_idx
on public.purchase_orders (
    organization_id,
    supplier_id,
    order_date desc
);

create index purchase_orders_status_date_idx
on public.purchase_orders (
    organization_id,
    status,
    order_date desc
);
alter table public.purchase_orders
add constraint purchase_orders_invoice_reference_unique
unique (id, organization_id);