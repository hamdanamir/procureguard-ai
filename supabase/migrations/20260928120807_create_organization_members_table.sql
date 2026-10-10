create table public.organization_members (
    id uuid primary key default gen_random_uuid(),

    organization_id uuid not null,
    user_id uuid not null,

    role text not null default 'VIEWER',
    status text not null default 'ACTIVE',

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    constraint organization_members_organization_fk
        foreign key (organization_id)
        references public.organizations(id)
        on delete cascade,

    constraint organization_members_user_fk
        foreign key (user_id)
        references auth.users(id)
        on delete cascade,

    constraint organization_members_role_check
        check (
            role in (
                'OWNER',
                'ADMIN',
                'PROCUREMENT_MANAGER',
                'REVIEWER',
                'VIEWER'
            )
        ),

    constraint organization_members_status_check
        check (
            status in (
                'ACTIVE',
                'INACTIVE',
                'SUSPENDED'
            )
        ),

    constraint organization_members_user_org_unique
        unique (organization_id, user_id)
);


create index organization_members_user_id_idx
    on public.organization_members(user_id);


create index organization_members_organization_id_idx
    on public.organization_members(organization_id);


create index organization_members_active_user_org_idx
    on public.organization_members(user_id, organization_id)
    where status = 'ACTIVE';


create trigger organization_members_set_updated_at
before update on public.organization_members
for each row
execute function public.set_updated_at();


alter table public.organization_members
enable row level security;