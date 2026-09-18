create extension if not exists pgcrypto;
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade,role text not null default 'customer' check(role in('customer','owner')),created_at timestamptz default now());
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id) values(new.id) on conflict(id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
create or replace function public.is_owner() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='owner'); $$;
create table if not exists public.products(id uuid primary key default gen_random_uuid(),name text not null,category text not null,description text,price numeric(12,2) not null default 0,stock integer not null default 0,image_url text,created_at timestamptz default now());
create table if not exists public.orders(id uuid primary key default gen_random_uuid(),customer_name text not null,phone text not null,address text,total numeric(12,2) default 0,status text not null default 'pending' check(status in('pending','confirmed','processing','ready','delivered','cancelled')),created_at timestamptz default now());
create table if not exists public.order_items(id uuid primary key default gen_random_uuid(),order_id uuid not null references public.orders(id) on delete cascade,product_id uuid references public.products(id) on delete set null,product_name text not null,quantity integer not null check(quantity>0),unit_price numeric(12,2) not null default 0);
alter table public.profiles enable row level security; alter table public.products enable row level security; alter table public.orders enable row level security; alter table public.order_items enable row level security;
drop policy if exists "products public read" on public.products; create policy "products public read" on public.products for select using(true);
drop policy if exists "owner product insert" on public.products; create policy "owner product insert" on public.products for insert to authenticated with check(public.is_owner());
drop policy if exists "owner product update" on public.products; create policy "owner product update" on public.products for update to authenticated using(public.is_owner()) with check(public.is_owner());
drop policy if exists "owner product delete" on public.products; create policy "owner product delete" on public.products for delete to authenticated using(public.is_owner());
drop policy if exists "public order insert" on public.orders; create policy "public order insert" on public.orders for insert with check(true);
drop policy if exists "owner order read" on public.orders; create policy "owner order read" on public.orders for select to authenticated using(public.is_owner());
drop policy if exists "owner order update" on public.orders; create policy "owner order update" on public.orders for update to authenticated using(public.is_owner()) with check(public.is_owner());
drop policy if exists "public item insert" on public.order_items; create policy "public item insert" on public.order_items for insert with check(true);
drop policy if exists "owner item read" on public.order_items; create policy "owner item read" on public.order_items for select to authenticated using(public.is_owner());
insert into storage.buckets(id,name,public) values('product-images','product-images',true) on conflict(id) do update set public=true;
drop policy if exists "product image read" on storage.objects; create policy "product image read" on storage.objects for select using(bucket_id='product-images');
drop policy if exists "owner image upload" on storage.objects; create policy "owner image upload" on storage.objects for insert to authenticated with check(bucket_id='product-images' and public.is_owner());
drop policy if exists "owner image delete" on storage.objects; create policy "owner image delete" on storage.objects for delete to authenticated using(bucket_id='product-images' and public.is_owner());
-- After creating the owner in Supabase Authentication, run:
-- update public.profiles set role='owner' where id='OWNER_AUTH_USER_UUID';
