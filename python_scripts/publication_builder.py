#!/usr/bin/env python3
"""Utilities for generating publication pages from publications.bib."""

from __future__ import annotations

import calendar
import os
import re
import shutil
import yaml
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, Tuple

from pybtex.database import parse_file


def clean_text(text: str) -> str:
    return (
        text.replace("{\\&}{\\#}xD;", "")
        .replace("{&}{\\#}xD;", "")
        .replace("\\&", "&")
        .replace("{", "")
        .replace("}", "")
    )


def get_paper_url_from_qmd(qmd_path: str) -> str:
    with open(qmd_path, encoding="utf-8") as f:
        content = f.read()
    m = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not m:
        return ""
    fm = yaml.safe_load(m.group(1))
    return fm.get("paper_url", "")


@dataclass
class PublicationGenerator:
    bib_path: str = "publications.bib"
    out_dir: str = "../publication"

    def __post_init__(self) -> None:
        self.bib_data = parse_file(self.bib_path)

    def dataframe(self) -> pd.DataFrame:
        import pandas as pd

        df = pd.DataFrame(columns=["entry", "year", "journal", "title"])
        for entry in self.bib_data.entries:
            f = self.bib_data.entries[entry].fields
            df = pd.concat(
                [
                    df,
                    pd.DataFrame(
                        [
                            {
                                "entry": entry,
                                "year": f.get("year", ""),
                                "journal": clean_text(f.get("journal", "")),
                                "title": clean_text(f.get("title", "")),
                            }
                        ]
                    ),
                ],
                ignore_index=True,
            )
        return df.sort_values(by=["year"], ascending=False)

    def _get_filenames(self, entry: str) -> Tuple[int, int, str, str]:
        year = int(self.bib_data.entries[entry].fields["year"])
        if "month" in self.bib_data.entries[entry].fields:
            bib_data_month = self.bib_data.entries[entry].fields["month"].capitalize()
            if bib_data_month in calendar.month_abbr:
                month = list(calendar.month_abbr).index(bib_data_month)
            elif bib_data_month in calendar.month_name:
                month = list(calendar.month_name).index(bib_data_month)
            else:
                month = datetime.now().month
        else:
            month = datetime.now().month

        pub_date = f"{year}-{month}-1"
        qmd_filename = f"{pub_date}-{entry}.qmd"
        html_filename = f"{pub_date}-{entry}"
        return year, month, qmd_filename, html_filename

    def _get_author(self, entry: str) -> str:
        people = self.bib_data.entries[entry].persons["author"]
        names = []
        for author in people:
            first = " ".join(author.bibtex_first_names).replace("{", "").replace("}", "")
            last = author.last_names[0].replace("{", "").replace("}", "")
            names.append(f"{first} {last}".strip())

        if not names:
            return ""
        if len(names) == 1:
            return names[0]
        return ", ".join(names[:-1]) + " and " + names[-1]

    def _get_journal(self, entry: str) -> Tuple[str, str, str, str, str]:
        f = self.bib_data.entries[entry].fields
        journal = clean_text(f.get("journal", ""))
        cit_journal = f"<i>{journal}</i>"
        if "volume" in f:
            cit_journal += f", {f['volume']}"
        if "pages" in f:
            cit_journal += f", {f['pages']}"
        if "doi" in f:
            cit_journal += f", doi:{f['doi']}"
        cit_journal += "."

        title = clean_text(f.get("title", ""))
        paper_url = f.get("url", "")
        excerpt = clean_text(f.get("abstract", ""))
        return journal, cit_journal, title, paper_url, excerpt

    def _slides_map(self) -> Dict[str, str]:
        slides_map: Dict[str, str] = {}
        slides_dir = os.path.join(os.path.dirname(self.out_dir), "files", "slides")
        if not os.path.isdir(slides_dir):
            return slides_map
        for fname in os.listdir(slides_dir):
            slug, ext = os.path.splitext(fname)
            if ext.lower() == ".pdf":
                slides_map[slug] = f"/files/slides/{fname}"
        return slides_map

    def _make_qmd(
        self,
        slug: str,
        title: str,
        year: int,
        author_list: str,
        journal: str,
        cit_journal: str,
        citation: str,
        paper_url: str,
        excerpt: str,
        slides_url: str = "",
    ) -> str:
        metadata = {
            "title": title,
            "pagetitle": f"{slug} - Gang Chen",
            "body-classes": "publication-page",
            "format": {"html": {"title-block-style": "none"}},
            "year": year,
            "author": author_list,
            "venue": journal,
            "venue_cit": cit_journal,
            "recommended_citation": citation,
        }

        if paper_url:
            metadata["paper_url"] = paper_url
        if slides_url:
            metadata["slides_url"] = slides_url
        if excerpt:
            abstract_clean = excerpt.replace("\n", " ").strip()
            metadata["abstract"] = abstract_clean

        front_matter = yaml.safe_dump(
            metadata,
            allow_unicode=True,
            sort_keys=False,
            default_flow_style=False,
        ).strip()

        lines = ["---", front_matter]

        lines.extend(
            [
                "---",
                "",
                "::: {.page-with-sidebar}",
                "",
                "::: {.sidebar-col}",
                "{{< include /_author-profile.qmd >}}",
                ":::",
                "",
                "::: {.content-col}",
                "",
                f"# {title}",
                "",
                f"*Published in {journal}, {year}*",
                "",
                f"**Recommended citation:** {citation}",
                "",
            ]
        )

        if excerpt:
            lines.extend(["## Abstract", "", excerpt.strip(), ""])
        if paper_url:
            lines.extend([f"[Download paper]({paper_url}){{target=\"_blank\"}}", ""])
        if slides_url:
            lines.extend([f"[Slides]({slides_url}){{target=\"_blank\"}}", ""])

        lines.extend([":::", "", ":::", ""])
        return "\n".join(lines)

    def _write_thesis_page(self) -> None:
        slug = "2007-7-1-Chen2007"
        title = "Mechanisms that control the latitude of jet streams and surface westerlies"
        thesis_qmd = self._make_qmd(
            slug=slug,
            title=title,
            year=2007,
            author_list="Chen, Gang",
            journal="Ph.D. thesis, Princeton University",
            cit_journal="Ph.D. thesis, Princeton University, 153 pp.",
            citation=f"Chen, Gang, 2007: {title}, Ph.D. thesis, Princeton University, 153 pp.",
            paper_url="/files/thesis.pdf",
            excerpt="",
            slides_url="",
        )
        with open(os.path.join(self.out_dir, f"{slug}.qmd"), "w", encoding="utf-8") as f:
            f.write(thesis_qmd)

    def build_pages(self, include_thesis: bool = True, copy_thesis_pdf: bool = True) -> int:
        os.makedirs(self.out_dir, exist_ok=True)
        slides_map = self._slides_map()

        count = 0
        for entry in self.bib_data.entries:
            year, _, qmd_filename, _ = self._get_filenames(entry)
            slug = os.path.splitext(os.path.basename(qmd_filename))[0]

            author_list = self._get_author(entry)
            journal, cit_journal, title, paper_url, excerpt = self._get_journal(entry)
            citation = f"{author_list}, {year}: {title}, {cit_journal}"
            excerpt = re.sub(r"^ABSTRACT\s*[:：]?\s*", "", excerpt, flags=re.IGNORECASE).strip()
            slides_url = slides_map.get(slug, "")

            qmd_content = self._make_qmd(
                slug,
                title,
                year,
                author_list,
                journal,
                cit_journal,
                citation,
                paper_url,
                excerpt,
                slides_url,
            )

            with open(os.path.join(self.out_dir, f"{slug}.qmd"), "w", encoding="utf-8") as f:
                f.write(qmd_content)
            count += 1

        if include_thesis:
            self._write_thesis_page()

        if copy_thesis_pdf and os.path.exists("thesis.pdf"):
            thesis_dst = "../files/thesis.pdf"
            if not os.path.exists(thesis_dst):
                shutil.copy("thesis.pdf", thesis_dst)

        return count
