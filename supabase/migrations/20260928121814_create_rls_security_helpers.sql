create or replace function public.is_organization_member(
    target_organization_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.organization_members om
        where om.organization_id = target_organization_id
          and om.user_id = auth.uid()
          and om.status = 'ACTIVE'
    );
$$;


create or replace function public.has_organization_role(
    target_organization_id uuid,
    allowed_roles text[]
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.organization_members om
        where om.organization_id = target_organization_id
          and om.user_id = auth.uid()
          and om.status = 'ACTIVE'
          and om.role = any(allowed_roles)
    );
$$;


revoke all on function public.is_organization_member(uuid)
from public;

revoke all on function public.has_organization_role(uuid, text[])
from public;


grant execute on function public.is_organization_member(uuid)
to authenticated;

grant execute on function public.has_organization_role(uuid, text[])
to authenticated;