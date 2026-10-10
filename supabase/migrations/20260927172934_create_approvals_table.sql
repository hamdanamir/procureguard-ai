-- The approvals table references anomalies using
-- (anomaly_id, organization_id), so create the required
-- composite unique constraint first.




create table public.approvals (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    anomaly_id uuid not null,

    invoice_id uuid not null,

    approval_type text not null
        check (
            approval_type in (
                'ANOMALY_REVIEW',
                'SUPPLIER_DISPUTE',
                'PAYMENT_HOLD',
                'MANUAL_OVERRIDE'
            )
        ),

    status text not null default 'PENDING'
        check (
            status in (
                'PENDING',
                'APPROVED',
                'REJECTED',
                'CANCELLED',
                'EXPIRED'
            )
        ),

    requested_by text,

    requested_at timestamptz not null default now(),

    decided_by text,

    decided_at timestamptz,

    decision_notes text,

    expires_at timestamptz,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint approvals_anomaly_organization_fk
        foreign key (anomaly_id, organization_id)
        references public.anomalies(id, organization_id)
        on delete restrict,

    constraint approvals_invoice_organization_fk
        foreign key (invoice_id, organization_id)
        references public.invoices(id, organization_id)
        on delete restrict,

    constraint approvals_decision_date_valid
        check (
            decided_at is null
            or decided_at >= requested_at
        ),

    constraint approvals_expiry_date_valid
        check (
            expires_at is null
            or expires_at >= requested_at
        ),

    constraint approvals_decision_consistency
        check (
            (
                status in ('PENDING', 'CANCELLED', 'EXPIRED')
                and decided_at is null
            )
            or
            (
                status in ('APPROVED', 'REJECTED')
                and decided_at is not null
            )
        )
);

create trigger set_approvals_updated_at
before update on public.approvals
for each row
execute function public.set_updated_at();

alter table public.approvals
enable row level security;

create index approvals_anomaly_idx
on public.approvals (
    organization_id,
    anomaly_id
);

create index approvals_invoice_idx
on public.approvals (
    organization_id,
    invoice_id
);

create index approvals_status_idx
on public.approvals (
    organization_id,
    status,
    requested_at desc
);

create index approvals_type_status_idx
on public.approvals (
    organization_id,
    approval_type,
    status
);