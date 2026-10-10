-- ============================================================
-- ORGANIZATIONS
-- ============================================================

create policy "members_can_read_organization"
on public.organizations
for select
to authenticated
using (
    public.is_organization_member(id)
);


-- ============================================================
-- ORGANIZATION MEMBERS
-- ============================================================

create policy "members_can_read_memberships"
on public.organization_members
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- SUPPLIERS
-- ============================================================

create policy "members_can_read_suppliers"
on public.suppliers
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- PRODUCTS
-- ============================================================

create policy "members_can_read_products"
on public.products
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- SUPPLIER PRODUCTS
-- ============================================================

create policy "members_can_read_supplier_products"
on public.supplier_products
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- PRODUCT ALIASES
-- ============================================================

create policy "members_can_read_product_aliases"
on public.product_aliases
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- PURCHASE ORDERS
-- ============================================================

create policy "members_can_read_purchase_orders"
on public.purchase_orders
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- PURCHASE ORDER ITEMS
-- ============================================================

create policy "members_can_read_purchase_order_items"
on public.purchase_order_items
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- INVOICES
-- ============================================================

create policy "members_can_read_invoices"
on public.invoices
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- INVOICE ITEMS
-- ============================================================

create policy "members_can_read_invoice_items"
on public.invoice_items
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- PRICE HISTORY
-- ============================================================

create policy "members_can_read_price_history"
on public.price_history
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- ANOMALIES
-- ============================================================

create policy "members_can_read_anomalies"
on public.anomalies
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- APPROVALS
-- ============================================================

create policy "members_can_read_approvals"
on public.approvals
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- AUDIT LOGS
-- ============================================================

create policy "members_can_read_audit_logs"
on public.audit_logs
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ============================================================
-- PROCESSING ERRORS
-- ============================================================

create policy "members_can_read_processing_errors"
on public.processing_errors
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);