-- ProcureGuard AI: platform-level configuration table.
-- Schema only: do not commit production setting values, email addresses, or secrets.
-- Apply in migration order to a fresh database; do not rerun on an existing table.

CREATE TABLE public.system_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    setting_key text NOT NULL,
    setting_value text NOT NULL,
    is_enabled boolean NOT NULL DEFAULT true,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT system_settings_key_unique UNIQUE (setting_key),
    CONSTRAINT system_settings_key_not_blank CHECK (btrim(setting_key) <> ''),
    CONSTRAINT system_settings_value_not_blank CHECK (btrim(setting_value) <> '')
);

ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
-- The verified source database has no RLS policies for this table.
-- Ordinary roles subject to RLS cannot access rows by default.
-- Restrict privileged backend access separately; never store credentials here.
