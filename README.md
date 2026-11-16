# University Guide

A multilingual university directory for prospective students. The site supports
English, Uzbek, and Russian, account sign-in, university search, and
administrator-only university entry.

## Publish with GitHub Pages

1. In the repository, open **Settings → Pages**.
2. Select **Deploy from a branch**, choose `main` and `/(root)`, and save.
3. Wait for GitHub Pages to publish the site at
   `https://ulashovsherali6-prog.github.io/university-guide/`.

## Configure Supabase

Run `setup.sql` in the Supabase SQL Editor. After creating and confirming your
account, use the administrator bootstrap statement at the end of `setup.sql`
with your account email.

In **Authentication → URL Configuration**, set the Site URL to the GitHub Pages
address above and add that same address ending in `index.html` to Redirect URLs.

## Search engine indexing

`robots.txt` allows crawling and points search engines to `sitemap.xml`. After
the public site is available, add it as a property in Google Search Console and
submit `https://ulashovsherali6-prog.github.io/university-guide/sitemap.xml`.
Search engines may take days or weeks to index a new site; indexing cannot be
guaranteed.
