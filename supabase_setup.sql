-- Run this in Supabase → SQL Editor (project odfkkcaacbtndxmfcikk — shared with
-- kind-patches-budget-tracker and higherdose-budget-tracker's Data API).
--
-- sys_budget_entries already exists with the DocuSign inbox columns (status,
-- source, category made nullable) from an earlier build — this is ONLY the
-- new Lumanu layer (2026-09-30), written as idempotent
-- ADD COLUMN IF NOT EXISTS statements so it's safe to run even if a column
-- below already happens to exist.
--
-- Every category in this tracker is influencer spend (there's no separate
-- shipping bucket like MadeGood/Moon Juice), so every confirmed row is
-- Lumanu-eligible once it has a source ('invoice_email') or attached
-- invoice — see PAID_CATS in docs/app.js.

ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'confirmed';
ALTER TABLE sys_budget_entries ALTER COLUMN category DROP NOT NULL;
ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'manual';

ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS billing_id text;
ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS due_date date;
ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS po_number text;
ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS lumanu_status text NOT NULL DEFAULT 'not_sent'
  CHECK (lumanu_status IN ('not_sent','needs_approval','approved','pending','issued','canceled'));
ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS lumanu_payable_id text;
ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS invoice_path text;
ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS contract_link text;
ALTER TABLE sys_budget_entries ADD COLUMN IF NOT EXISTS ready_to_invoice boolean NOT NULL DEFAULT false;

-- Only needed once for this whole shared project (odfkkcaacbtndxmfcikk) — skip
-- if kind-patches-budget-tracker or higherdose-budget-tracker's setup already
-- created it. Supabase → Storage → New bucket → name it exactly "invoices" →
-- leave "Public bucket" UNCHECKED (the bridge hands back short-lived signed
-- URLs, never a public link).
