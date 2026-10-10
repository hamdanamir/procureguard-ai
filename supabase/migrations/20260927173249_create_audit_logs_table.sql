create table public.audit_logs (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null
        references public.organizations(id)
        on delete restrict,

    entity_type text not null
        check (
            entity_type in (
                'ORGANIZATION',
                'SUPPLIER',
                'PRODUCT',
                'SUPPLIER_PRODUCT',
                'PRODUCT_ALIAS',
                'PURCHASE_ORDER',
                'PURCHASE_ORDER_ITEM',
                'INVOICE',
                'INVOICE_ITEM',
                'PRICE_HISTORY',
                'ANOMALY',
                'APPROVAL',
                'PROCESSING_ERROR'
            )
        ),

    entity_id uuid,

    action text not null
        check (
            action in (
                'CREATE',
                'UPDATE',
                'DELETE',
                'STATUS_CHANGE',
                'DETECT',
                'REVIEW',
                'APPROVE',
                'REJECT',
                'DISMISS',
                'RESOLVE',
                'PROCESS',
                'FAIL',
                'RETRY',
                'SEND',
                'HOLD',
                'OVERRIDE'
            )
        ),

    actor_type text not null default 'SYSTEM'
        check (
            actor_type in (
                'USER',
                'SYSTEM',
                'AI',
                'WEBHOOK',
                'N8N'
            )
        ),

    actor_id text,

    source text,

    description text not null,

    old_values jsonb,

    new_values jsonb,

    metadata jsonb,

    created_at timestamptz not null default now(),

    constraint audit_logs_description_not_blank
        check (
            btrim(description) <> ''
        )
);

alter table public.audit_logs
enable row level security;

create index audit_logs_entity_idx
on public.audit_logs (
    organization_id,
    entity_type,
    entity_id,
    created_at desc
);

create index audit_logs_actor_idx
on public.audit_logs (
    organization_id,
    actor_type,
    actor_id,
    created_at desc
);

create index audit_logs_action_idx
on public.audit_logs (
    organization_id,
    action,
    created_at desc
);

create index audit_logs_created_at_idx
on public.audit_logs (
    organization_id,
    created_at desc
);