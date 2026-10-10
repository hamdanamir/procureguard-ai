create table public.invoices (
    constraint invoices_id_organization_unique
    unique (id, organization_id),
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    supplier_id uuid not null,

    purchase_order_id uuid,

    invoice_number text not null,

    invoice_date date not null,

    due_date date,

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

    document_url text,

    document_hash text,

    source_message_id text,

    processing_status text not null default 'RECEIVED'
        check (
            processing_status in (
                'RECEIVED',
                'PROCESSING',
                'PROCESSED',
                'REVIEW_REQUIRED',
                'REJECTED',
                'FAILED'
            )
        ),

    notes text,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint invoices_supplier_organization_fk
        foreign key (supplier_id, organization_id)
        references public.suppliers(id, organization_id)
        on delete restrict,

    constraint invoices_po_organization_fk
        foreign key (purchase_order_id, organization_id)
        references public.purchase_orders(id, organization_id)
        on delete restrict,

    constraint invoices_number_not_blank
        check (btrim(invoice_number) <> ''),

    constraint invoices_due_date_valid
        check (
            due_date is null
            or due_date >= invoice_date
        ),

    constraint invoices_total_consistent
        check (
            total =
            subtotal
            + tax
            + additional_charges
            - discount
        ),

    constraint invoices_supplier_number_unique
        unique (
            organization_id,
            supplier_id,
            invoice_number
        ),

    constraint invoices_document_hash_unique
        unique (
            organization_id,
            document_hash
        )
);

create trigger set_invoices_updated_at
before update on public.invoices
for each row
execute function public.set_updated_at();

alter table public.invoices
enable row level security;

create index invoices_supplier_date_idx
on public.invoices (
    organization_id,
    supplier_id,
    invoice_date desc
);

create index invoices_po_idx
on public.invoices (
    organization_id,
    purchase_order_id
);

create index invoices_processing_status_idx
on public.invoices (
    organization_id,
    processing_status,
    created_at desc
);