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

create table if not exists public.ticket_codes (
  code text primary key,
  is_used boolean not null default false,
  used_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.ticket_codes enable row level security;

drop policy if exists "Allow public read ticket codes" on public.ticket_codes;
create policy "Allow public read ticket codes"
  on public.ticket_codes
  for select
  to anon
  using (true);

grant select on public.ticket_codes to anon;

insert into public.ticket_codes (code, is_used)
values
  ('GLOW', false),
  ('ROCK', false),
  ('ROLL', false),
  ('SING', false),
  ('WAVE', false),
  ('VIBE', false),
  ('ECHO', false),
  ('MUSE', false),
  ('MOON', false),
  ('STAR', false),
  ('LUCK', false),
  ('WISH', false),
  ('RING', false),
  ('HOPE', false),
  ('LIVE', false),
  ('SOUL', false),
  ('BEAT', false),
  ('BELL', false)
on conflict (code) do update
set is_used = false,
    used_at = null;

create or replace function public.use_ticket_code(ticket_code_input text)
returns table (code text, status text)
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_code text := upper(trim(ticket_code_input));
begin
  update public.ticket_codes
  set is_used = true,
      used_at = now()
  where ticket_codes.code = normalized_code
    and ticket_codes.is_used = false
  returning ticket_codes.code, 'confirmed'::text
  into code, status;

  if found then
    return next;
    return;
  end if;

  if exists (
    select 1
    from public.ticket_codes
    where ticket_codes.code = normalized_code
      and ticket_codes.is_used = true
  ) then
    code := normalized_code;
    status := 'used';
    return next;
    return;
  end if;

  code := normalized_code;
  status := 'invalid';
  return next;
end;
$$;

grant execute on function public.use_ticket_code(text) to anon;
