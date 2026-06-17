create table if not exists public.ticket_input_logs (
  id uuid primary key default gen_random_uuid(),
  ticket_code text not null,
  status text not null check (status in ('valid', 'used', 'invalid')),
  created_at timestamptz not null default now()
);

alter table public.ticket_input_logs enable row level security;

drop policy if exists "Allow public insert ticket input logs" on public.ticket_input_logs;
create policy "Allow public insert ticket input logs"
  on public.ticket_input_logs
  for insert
  to anon
  with check (true);
