create table public.processing_errors (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid
        references public.organizations(id)
        on delete restrict,

    invoice_id uuid,

    invoice_item_id uuid,

    error_stage text not null
        check (
            error_stage in (
                'EMAIL_RECEIVED',
                'DOCUMENT_DOWNLOAD',
                'DOCUMENT_PARSE',
                'AI_EXTRACTION',
                'DATA_VALIDATION',
                'SUPPLIER_MATCH',
                'PRODUCT_MATCH',
                'PO_MATCH',
                'DATABASE',
                'ANOMALY_DETECTION',
                'APPROVAL',
                'NOTIFICATION',
                'UNKNOWN'
            )
        ),

    error_code text not null,

    error_message text not null,

    technical_details text,

    severity text not null default 'ERROR'
        check (
            severity in (
                'WARNING',
                'ERROR',
                'CRITICAL'
            )
        ),

    status text not null default 'OPEN'
        check (
            status in (
                'OPEN',
                'RETRYING',
                'RESOLVED',
                'IGNORED'
            )
        ),

    retry_count integer not null default 0
        check (retry_count >= 0),

    workflow_name text,

    workflow_execution_id text,

    source_message_id text,

    context jsonb,

    occurred_at timestamptz not null default now(),

    resolved_at timestamptz,

    resolution_notes text,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint processing_errors_invoice_organization_fk
        foreign key (invoice_id, organization_id)
        references public.invoices(id, organization_id)
        on delete restrict,

    constraint processing_errors_invoice_item_organization_fk
        foreign key (invoice_item_id, organization_id)
        references public.invoice_items(id, organization_id)
        on delete restrict,

    constraint processing_errors_code_not_blank
        check (
            btrim(error_code) <> ''
        ),

    constraint processing_errors_message_not_blank
        check (
            btrim(error_message) <> ''
        ),

    constraint processing_errors_resolution_date_valid
        check (
            resolved_at is null
            or resolved_at >= occurred_at
        ),

    constraint processing_errors_status_resolution_valid
        check (
            (
                status in ('OPEN', 'RETRYING', 'IGNORED')
                and resolved_at is null
            )
            or
            (
                status = 'RESOLVED'
                and resolved_at is not null
            )
        )
);

create trigger set_processing_errors_updated_at
before update on public.processing_errors
for each row
execute function public.set_updated_at();

alter table public.processing_errors
enable row level security;

create index processing_errors_invoice_idx
on public.processing_errors (
    organization_id,
    invoice_id,
    occurred_at desc
);

create index processing_errors_stage_status_idx
on public.processing_errors (
    organization_id,
    error_stage,
    status,
    occurred_at desc
);

create index processing_errors_severity_idx
on public.processing_errors (
    organization_id,
    severity,
    status,
    occurred_at desc
);

create index processing_errors_execution_idx
on public.processing_errors (
    organization_id,
    workflow_execution_id,
    occurred_at desc
);