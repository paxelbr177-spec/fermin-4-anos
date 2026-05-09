# Fermín faz 4 anos! 🎂

Página estática com mural de recados e chá virtual, hospedada no GitHub Pages, com backend Supabase.

## Estrutura

```
fermin-site/
├── index.html         ← Single-page React (CDN), edite os 2 valores no topo
├── schema.sql         ← Rodar uma vez no SQL Editor do Supabase
├── README.md          ← Este arquivo
└── assets/
    ├── 01-boca.jpg
    ├── 02-surf.jpg
    ├── 03-por-do-sol.jpg
    ├── 04-aventura.jpg
    ├── 05-estiloso.jpg
    ├── 06-telefone.jpg
    └── 07-banho.jpg
```

---

## Deploy — passo a passo

### 1. Criar projeto Supabase

- Acesse https://supabase.com/dashboard → **New project**
- Nome: `fermin-4-anos` (ou o que preferir)
- Região: **South America (São Paulo)** — menor latência pra você e família no Brasil/Argentina
- Database password: gera uma forte e guarda no gerenciador de senhas
- Plan: **Free** (mais que suficiente — limite é 500MB DB + 5GB egress/mês)
- Aguarde ~2 min até o projeto provisionar.

### 2. Rodar o schema

- No painel do projeto: **SQL Editor** → **New query**
- Cole TODO o conteúdo de `schema.sql`
- Clique **Run**
- Verifique no **Table Editor** que apareceram 2 tabelas:
  - `fermin_recados`
  - `fermin_presentes_contador`

### 3. Pegar URL e anon key

- **Settings** → **API** (ou **Data API** dependendo da versão do dashboard)
- Copie:
  - **Project URL** (ex: `https://abcdefgh.supabase.co`)
  - **anon / public key** (a longa que começa com `eyJ...`)
    - ⚠️ **Não use a service_role key** — ela tem privilégios de admin e nunca deve ir no front-end.

### 4. Editar `index.html`

Abra `index.html` em qualquer editor e localize as duas linhas no topo do `<script type="text/babel">`:

```js
const SUPABASE_URL      = 'COLE_AQUI_https://xxxxxxxxx.supabase.co';
const SUPABASE_ANON_KEY = 'COLE_AQUI_eyJhbGciOiJIUzI1NiIsInR5cCI6...';
```

Substitua pelos valores do passo 3.

### 5. Testar localmente (opcional mas recomendado)

```bash
cd fermin-site
python3 -m http.server 8000
# abre no navegador: http://localhost:8000
```

Deixe um recadinho de teste, clique em um presente. Confirme no Supabase Table Editor que apareceram. Se aparecer, deploy. Se não:
- Abra o DevTools (F12) → Console e veja o erro
- Geralmente é URL/key errada, ou o `schema.sql` não rodou completo

### 6. Subir no GitHub

```bash
cd fermin-site
git init
git add .
git commit -m "Página de aniversário do Fermín"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/fermin-4-anos.git
git push -u origin main
```

Cria primeiro o repo vazio em https://github.com/new (público, sem README inicial).

### 7. Ativar GitHub Pages

- No repo: **Settings** → **Pages**
- **Source:** Deploy from a branch
- **Branch:** `main` / `/ (root)`
- **Save**
- Aguarde ~1-2 min. URL final será: `https://SEU_USUARIO.github.io/fermin-4-anos/`

---

## Customizações rápidas

Tudo que pode mudar tá no objeto `CONFIG` no topo do `<script type="text/babel">`:

```js
const CONFIG = {
  nomeAniversariante: 'Fermín',
  idade: 4,
  dataFesta: '21 de maio de 2026',
  diaSemana: 'quinta-feira',
  pagamento: { ... },
  fotos:     [ ... ],
  presentes: [ ... ],
};
```

- **Adicionar foto:** `{ url: './assets/08-novafoto.jpg', caption: 'Caption legal 🎉' }` no array `fotos`
- **Mudar valor de presente:** edita `valor:` no array `presentes`
- **Trocar chave PIX:** edita `chave:` em `pagamento.br`

---

## Moderação

Se aparecer mensagem indesejada:

```sql
-- No SQL Editor do Supabase
delete from public.fermin_recados where id = 'UUID_DO_RECADO';

-- Ou ver os últimos 20 pra triar:
select * from public.fermin_recados order by created_at desc limit 20;
```

---

## Limites e considerações

- **Free tier do Supabase:** 500MB DB, 5GB egress/mês, 50k MAU. Pra um chá de família é ~10000x mais que o necessário.
- **Realtime habilitado:** mensagens aparecem ao vivo pra quem estiver na página. Se quiser desativar, comente as linhas `alter publication supabase_realtime add table ...` no `schema.sql`.
- **Anon key no front é segura por design** — RLS só permite SELECT/INSERT em recados e SELECT no contador. Mutação do contador só via RPC com `security definer`.
- **Rate limiting:** Supabase tem proteção básica contra abuse. Se virar problema (improvável), dá pra adicionar lógica adicional.

---

## Próximos passos opcionais

- **Custom domain:** apontar `fermin.jurimetrix.com` via CNAME pro `seu-usuario.github.io` (precisa habilitar custom domain nas Settings do Pages e adicionar registro DNS)
- **OG image dinâmica:** atualmente usa `assets/01-boca.jpg` no preview do WhatsApp. Trocar editando a meta tag `<meta property="og:image" ... />` no `<head>`
- **Backup de mensagens:** depois do aniversário, exportar via SQL: `select * from fermin_recados order by created_at;` e salvar de lembrança
 
 
 