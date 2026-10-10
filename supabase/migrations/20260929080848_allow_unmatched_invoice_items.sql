ALTER TABLE public.invoice_items
ALTER COLUMN product_id DROP NOT NULL;

COMMENT ON COLUMN public.invoice_items.product_id IS
'Internal product matched to the invoice line. NULL when the supplier invoice line has not yet been confidently mapped to an internal product.';