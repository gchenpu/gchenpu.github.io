# Gang Chen's Personal Website

This repository contains a Quarto-based personal academic website.

## What this site includes

- Main pages: `index.qmd`, `group.qmd`, `publications.qmd`, `cv.qmd`, `code.qmd`
- Site configuration in `_quarto.yml`
- GitHub Pages workflow in `.github/workflows/publish.yml`

## Local rendering

From repository root:

```bash
quarto render
```

Rendered output is written to `_site/`.

## Publishing (GitHub Actions)

Publishing is automatic on push to the `main` branch via `.github/workflows/publish.yml`.
