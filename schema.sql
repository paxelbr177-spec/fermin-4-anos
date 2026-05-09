-- ============================================================================
-- SCHEMA — Página de aniversário do Fermín (4 anos)
-- ============================================================================
-- Como rodar:
--   1. Crie um projeto novo no Supabase: https://supabase.com/dashboard
--      (sugestão de nome: "fermin-4-anos", região: South America - São Paulo)
--   2. Vá em SQL Editor → New query
--   3. Cole TODO este arquivo e clique Run
--   4. Vá em Settings → API e copie a URL e a anon (publishable) key
--   5. Cole no topo do index.html
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. TABELAS
-- ----------------------------------------------------------------------------

-- Mural de recados (todos os visitantes podem ler e escrever)
create table if not exists public.fermin_recados (
  id          uuid        primary key default gen_random_uuid(),
  nome        text        not null check (char_length(trim(nome)) between 1 and 60),
  mensagem    text        not null check (char_length(trim(mensagem)) between 1 and 400),
  created_at  timestamptz not null default now()
);

create index if not exists idx_recados_created on public.fermin_recados (created_at desc);

-- Contador de presentes (uma linha por categoria, incrementa atomicamente via RPC)
create table if not exists public.fermin_presentes_contador (
  gift_id     text        primary key check (char_length(gift_id) between 1 and 30),
  count       int         not null default 0 check (count >= 0),
  updated_at  timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2. FUNÇÃO RPC — incremento atômico do contador de presentes
-- ----------------------------------------------------------------------------
-- Usa security definer pra contornar RLS (anon não pode fazer UPDATE direto,
-- mas pode chamar essa função que faz o trabalho com privilégios do owner).

create or replace function public.incrementar_presente(p_gift_id text)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  novo_count int;
begin
  if p_gift_id is null or char_length(trim(p_gift_id)) = 0 or char_length(p_gift_id) > 30 then
    raise exception 'gift_id inválido';
  end if;

  insert into public.fermin_presentes_contador (gift_id, count, updated_at)
  values (p_gift_id, 1, now())
  on conflict (gift_id) do update
     set count = fermin_presentes_contador.count + 1,
         updated_at = now()
  returning count into novo_count;

  return novo_count;
end;
$$;

-- ----------------------------------------------------------------------------
-- 3. ROW LEVEL SECURITY
-- ----------------------------------------------------------------------------

alter table public.fermin_recados              enable row level security;
alter table public.fermin_presentes_contador   enable row level security;

-- Recados: anon pode SELECT (ver) e INSERT (deixar recado)
drop policy if exists "anon_select_recados" on public.fermin_recados;
create policy "anon_select_recados"
  on public.fermin_recados for select
  using (true);

drop policy if exists "anon_insert_recados" on public.fermin_recados;
create policy "anon_insert_recados"
  on public.fermin_recados for insert
  with check (true);

-- Contador: anon só pode SELECT (ler).
-- Mutação só via RPC incrementar_presente (que tem security definer).
drop policy if exists "anon_select_contador" on public.fermin_presentes_contador;
create policy "anon_select_contador"
  on public.fermin_presentes_contador for select
  using (true);

-- ----------------------------------------------------------------------------
-- 4. PERMISSÕES — anon pode chamar a RPC
-- ----------------------------------------------------------------------------

grant execute on function public.incrementar_presente(text) to anon, authenticated;

-- ----------------------------------------------------------------------------
-- 5. REALTIME — habilita publicação para subscribers verem mudanças ao vivo
-- ----------------------------------------------------------------------------

do $$
begin
  alter publication supabase_realtime add table public.fermin_recados;
exception when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.fermin_presentes_contador;
exception when duplicate_object then null;
end $$;

-- ============================================================================
-- VERIFICAÇÃO — execute essas queries depois para conferir que deu tudo certo
-- ============================================================================
-- select * from public.fermin_recados;
-- select * from public.fermin_presentes_contador;
-- select public.incrementar_presente('teste');  -- deve retornar 1
-- select public.incrementar_presente('teste');  -- deve retornar 2
-- delete from public.fermin_presentes_contador where gift_id = 'teste';
-- ============================================================================
