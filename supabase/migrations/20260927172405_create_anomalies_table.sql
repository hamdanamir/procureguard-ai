

create table public.anomalies (

    
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    invoice_id uuid not null,

    invoice_item_id uuid,

    supplier_id uuid not null,

    product_id uuid,

    purchase_order_id uuid,

    anomaly_type text not null
        check (
            anomaly_type in (
                'PRICE_VARIANCE',
                'QUANTITY_VARIANCE',
                'DUPLICATE_INVOICE',
                'MISSING_PO',
                'UNKNOWN_PRODUCT',
                'UNEXPECTED_CHARGE'
            )
        ),

    severity text not null default 'LOW'
        check (
            severity in (
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    status text not null default 'OPEN'
        check (
            status in (
                'OPEN',
                'UNDER_REVIEW',
                'CONFIRMED',
                'DISMISSED',
                'RESOLVED'
            )
        ),

    expected_value numeric(14,2),

    actual_value numeric(14,2),

    variance_amount numeric(14,2),

    variance_percent numeric(7,3),

    estimated_financial_impact numeric(14,2)
        not null default 0.00
        check (estimated_financial_impact >= 0),

    description text not null,

    evidence jsonb,

    detected_at timestamptz not null default now(),

    reviewed_at timestamptz,

    resolved_at timestamptz,

    reviewed_by text,

    resolution_notes text,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),
    
    constraint anomalies_id_organization_unique
    unique (id, organization_id),

    constraint anomalies_invoice_organization_fk
        foreign key (invoice_id, organization_id)
        references public.invoices(id, organization_id)
        on delete restrict,

    constraint anomalies_invoice_item_organization_fk
        foreign key (invoice_item_id, organization_id)
        references public.invoice_items(id, organization_id)
        on delete restrict,

    constraint anomalies_supplier_organization_fk
        foreign key (supplier_id, organization_id)
        references public.suppliers(id, organization_id)
        on delete restrict,

    constraint anomalies_product_organization_fk
        foreign key (product_id, organization_id)
        references public.products(id, organization_id)
        on delete restrict,

    constraint anomalies_po_organization_fk
        foreign key (purchase_order_id, organization_id)
        references public.purchase_orders(id, organization_id)
        on delete restrict,

    constraint anomalies_variance_percent_valid
        check (
            variance_percent is null
            or variance_percent >= -100
        ),

    constraint anomalies_review_date_valid
        check (
            reviewed_at is null
            or reviewed_at >= detected_at
        ),

    constraint anomalies_resolution_date_valid
        check (
            resolved_at is null
            or resolved_at >= detected_at
        ),

    constraint anomalies_description_not_blank
        check (
            btrim(description) <> ''
        )
);

create trigger set_anomalies_updated_at
before update on public.anomalies
for each row
execute function public.set_updated_at();

alter table public.anomalies
enable row level security;

create index anomalies_invoice_idx
on public.anomalies (
    organization_id,
    invoice_id
);

create index anomalies_supplier_idx
on public.anomalies (
    organization_id,
    supplier_id,
    detected_at desc
);

create index anomalies_type_status_idx
on public.anomalies (
    organization_id,
    anomaly_type,
    status,
    detected_at desc
);

create index anomalies_severity_idx
on public.anomalies (
    organization_id,
    severity,
    status
);