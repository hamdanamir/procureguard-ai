-- ProcureGuard AI: organization-specific daily report configuration.
-- Schema-only migration. No production recipients or organization records.
-- Apply to a fresh database in migration order; do not rerun on a database
-- where this table already exists.

CREATE TABLE public.organization_report_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    daily_report_enabled boolean NOT NULL DEFAULT true,
    daily_report_recipient text NOT NULL,
    timezone text NOT NULL DEFAULT 'Asia/Karachi',
    report_hour smallint NOT NULL DEFAULT 8,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT organization_report_settings_org_unique UNIQUE (organization_id),
    CONSTRAINT organization_report_settings_recipient_not_blank
        CHECK (btrim(daily_report_recipient) <> ''),
    CONSTRAINT organization_report_settings_hour_check
        CHECK (report_hour BETWEEN 0 AND 23)
);

ALTER TABLE public.organization_report_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY members_can_read_organization_report_settings
ON public.organization_report_settings
FOR SELECT TO authenticated
USING (public.is_organization_member(organization_id));

CREATE POLICY authorized_roles_can_insert_organization_report_settings
ON public.organization_report_settings
FOR INSERT TO authenticated
WITH CHECK (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER'::text, 'ADMIN'::text, 'PROCUREMENT_MANAGER'::text]
    )
);

CREATE POLICY authorized_roles_can_update_organization_report_settings
ON public.organization_report_settings
FOR UPDATE TO authenticated
USING (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER'::text, 'ADMIN'::text, 'PROCUREMENT_MANAGER'::text]
    )
)
WITH CHECK (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER'::text, 'ADMIN'::text, 'PROCUREMENT_MANAGER'::text]
    )
);

CREATE POLICY admins_can_delete_organization_report_settings
ON public.organization_report_settings
FOR DELETE TO authenticated
USING (
    public.has_organization_role(
        organization_id,
        ARRAY['OWNER'::text, 'ADMIN'::text]
    )
);
