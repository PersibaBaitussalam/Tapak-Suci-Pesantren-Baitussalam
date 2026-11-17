-- Jalankan seluruh isi file ini di Supabase Dashboard > SQL Editor.
-- GANTI alamat email di tiga policy admin di bawah dengan email admin yang sebenarnya.

create extension if not exists pgcrypto;

create table if not exists public.anggota (
  id uuid primary key default gen_random_uuid(),
  jenjang text not null check (jenjang in ('siswa','kader','pendekar')),
  nama text not null,
  jk text,
  tahun integer,
  tingkat text,
  kta text,
  alamat text,
  kontak text,
  foto text,
  kta_img text,
  keg jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.anggota enable row level security;

drop policy if exists "Anggota dapat dibaca publik" on public.anggota;
create policy "Anggota dapat dibaca publik"
  on public.anggota for select
  to anon, authenticated
  using (true);

drop policy if exists "Admin dapat menambah anggota" on public.anggota;
create policy "Admin dapat menambah anggota"
  on public.anggota for insert
  to authenticated
  with check (lower(coalesce(auth.jwt()->>'email','')) = lower('baitussalamtapaksuci@gmail.com'));

drop policy if exists "Admin dapat mengubah anggota" on public.anggota;
create policy "Admin dapat mengubah anggota"
  on public.anggota for update
  to authenticated
  using (lower(coalesce(auth.jwt()->>'email','')) = lower('baitussalamtapaksuci@gmail.com'))
  with check (lower(coalesce(auth.jwt()->>'email','')) = lower('baitussalamtapaksuci@gmail.com'));

drop policy if exists "Admin dapat menghapus anggota" on public.anggota;
create policy "Admin dapat menghapus anggota"
  on public.anggota for delete
  to authenticated
  using (lower(coalesce(auth.jwt()->>'email','')) = lower('baitussalamtapaksuci@gmail.com'));

-- Bucket foto publik agar URL foto dapat ditampilkan di halaman web.
insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do update set public = true;

drop policy if exists "Foto anggota dapat dilihat publik" on storage.objects;
create policy "Foto anggota dapat dilihat publik"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'media');

drop policy if exists "Admin dapat mengunggah foto" on storage.objects;
create policy "Admin dapat mengunggah foto"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'media' and lower(coalesce(auth.jwt()->>'email','')) = lower('baitussalamtapaksuci@gmail.com'));

drop policy if exists "Admin dapat memperbarui foto" on storage.objects;
create policy "Admin dapat memperbarui foto"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'media' and lower(coalesce(auth.jwt()->>'email','')) = lower('baitussalamtapaksuci@gmail.com'))
  with check (bucket_id = 'media' and lower(coalesce(auth.jwt()->>'email','')) = lower('baitussalamtapaksuci@gmail.com'));

drop policy if exists "Admin dapat menghapus foto" on storage.objects;
create policy "Admin dapat menghapus foto"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'media' and lower(coalesce(auth.jwt()->>'email','')) = lower('baitussalamtapaksuci@gmail.com'));
