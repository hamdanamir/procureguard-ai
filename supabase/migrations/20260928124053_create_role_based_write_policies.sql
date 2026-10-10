-- ============================================================
-- MASTER + PROCUREMENT DATA
-- OWNER / ADMIN / PROCUREMENT_MANAGER can write
-- ============================================================

do $$
declare
    tbl text;
begin
    foreach tbl in array array[
        'suppliers',
        'products',
        'supplier_products',
        'product_aliases',
        'purchase_orders',
        'purchase_order_items',
        'invoices',
        'invoice_items',
        'price_history'
    ]
    loop

        execute format(
            'create policy %I on public.%I
             for insert
             to authenticated
             with check (
                 public.has_organization_role(
                     organization_id,
                     ARRAY[''OWNER'',''ADMIN'',''PROCUREMENT_MANAGER'']
                 )
             )',
            'authorized_roles_can_insert_' || tbl,
            tbl
        );

        execute format(
            'create policy %I on public.%I
             for update
             to authenticated
             using (
                 public.has_organization_role(
                     organization_id,
                     ARRAY[''OWNER'',''ADMIN'',''PROCUREMENT_MANAGER'']
                 )
             )
             with check (
                 public.has_organization_role(
                     organization_id,
                     ARRAY[''OWNER'',''ADMIN'',''PROCUREMENT_MANAGER'']
                 )
             )',
            'authorized_roles_can_update_' || tbl,
            tbl
        );

        execute format(
            'create policy %I on public.%I
             for delete
             to authenticated
             using (
                 public.has_organization_role(
                     organization_id,
                     ARRAY[''OWNER'',''ADMIN'']
                 )
             )',
            'admins_can_delete_' || tbl,
            tbl
        );

    end loop;
end
$$;


-- ============================================================
-- ANOMALIES
-- Procurement roles can create/update.
-- Only OWNER/ADMIN can delete.
-- ============================================================

create policy "authorized_roles_can_insert_anomalies"
on public.anomalies
for insert
to authenticated
with check (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER','ADMIN','PROCUREMENT_MANAGER']
    )
);


create policy "reviewers_can_update_anomalies"
on public.anomalies
for update
to authenticated
using (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER','ADMIN','PROCUREMENT_MANAGER','REVIEWER']
    )
)
with check (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER','ADMIN','PROCUREMENT_MANAGER','REVIEWER']
    )
);


create policy "admins_can_delete_anomalies"
on public.anomalies
for delete
to authenticated
using (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER','ADMIN']
    )
);


-- ============================================================
-- APPROVALS
-- Reviewer participates here.
-- ============================================================

create policy "authorized_roles_can_insert_approvals"
on public.approvals
for insert
to authenticated
with check (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER','ADMIN','PROCUREMENT_MANAGER','REVIEWER']
    )
);


create policy "reviewers_can_update_approvals"
on public.approvals
for update
to authenticated
using (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER','ADMIN','PROCUREMENT_MANAGER','REVIEWER']
    )
)
with check (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER','ADMIN','PROCUREMENT_MANAGER','REVIEWER']
    )
);


create policy "admins_can_delete_approvals"
on public.approvals
for delete
to authenticated
using (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER','ADMIN']
    )
);