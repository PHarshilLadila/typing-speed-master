-- Supabase Storage Setup for Profile Avatars
-- Run this in Supabase SQL Editor after creating the 'profiles' bucket

-- ============================================================
-- STEP 1: Create the storage bucket (do this in UI first)
-- ============================================================
-- 1. Go to Supabase Dashboard → Storage
-- 2. Click "New bucket"
-- 3. Name: profiles
-- 4. Public: Yes (checked)
-- 5. Click "Save"

-- ============================================================
-- STEP 2: Run these SQL policies
-- ============================================================

-- Allow authenticated users to upload their own avatar
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profiles' 
  AND (storage.foldername(name))[1] = 'avatars'
);

-- Allow public read access to avatars
CREATE POLICY "Public avatar access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profiles');

-- Allow users to update their own avatar
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profiles' 
  AND (storage.foldername(name))[1] = 'avatars'
);

-- Allow users to delete their own avatar
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profiles' 
  AND (storage.foldername(name))[1] = 'avatars'
);

-- ============================================================
-- STEP 3: Verify the setup
-- ============================================================
-- Run this query to check if policies are created:
SELECT 
  policyname,
  cmd,
  roles,
  qual
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects';

-- Expected output: 4 policies related to profiles bucket

-- ============================================================
-- Optional: Set file size limits
-- ============================================================
-- You can set maximum file size in the bucket settings:
-- Supabase Dashboard → Storage → profiles → Settings
-- Recommended: 5 MB for profile pictures
