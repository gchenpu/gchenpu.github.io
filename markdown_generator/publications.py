
# coding: utf-8

# ## Escape special characters
# 
# YAML is very picky about how it takes a valid string, so we are replacing single and double quotes (and ampersands) with their HTML encoded equivilents. This makes them look not so readable in raw format, but they are parsed and rendered nicely.

# In[5]:


html_escape_table = {
    "&": "&amp;",
    '"': "&quot;",
    "'": "&apos;"
    }

def html_escape(text):
    """Produce entities within text."""
    return "".join(html_escape_table.get(c,c) for c in text)


# ## Publications markdown generator
# 
# Takes a list of publications in .bib format and converts them for use. This is an interactive Jupyter notebook. The core python code is also in `publications.py`. Run either from the `markdown_generator` folder after replacing `publications.bib` with one containing your data.

# In[9]:


import os
import calendar
from pybtex.database import parse_file

bib_data = parse_file('publications.bib')
#print(bib_data)

for entry in bib_data.entries:
# create the name of each md file
    year  = bib_data.entries[entry].fields['year']
    if 'month' in bib_data.entries[entry].fields:
        month = list(calendar.month_abbr).index(bib_data.entries[entry].fields['month'].capitalize())
    else:
        month = 1
    pub_date = str(year) + "-" + str(month) + "-" + "1"
    
    md_filename   = pub_date + "-" + entry + ".md"
    html_filename = pub_date + "-" + entry
    #print(md_filename)
    
# cp pdf files to ../files and set up the link
    if 'file' in bib_data.entries[entry].fields:
        path = '/mnt/c' + bib_data.entries[entry].fields['file'][15:-4]
        path = path.replace(" ",    "\ ")
        path = path.replace("{\_}", "\_")
        os.system("cp " + path + " ../files")
        download_filename = '/files/' + os.path.basename(path).replace("\\", "")
    else:
        download_filename = ''
    #print(download_filename)

# set up author names
    num_author=len(bib_data.entries[entry].persons['author'])
    for count, author in enumerate(bib_data.entries[entry].persons['author']):
        if count == 0:
            author_list = author.last_names[0] + ", "
            for cc, first in enumerate(author.bibtex_first_names):
                if cc <len(author.bibtex_first_names)-1:
                    author_list += first + " "
                else:
                    author_list += first
        elif count < num_author-1:
            author_list += ", " 
            for cc, first in enumerate(author.bibtex_first_names):
                if cc <len(author.bibtex_first_names)-1:
                    author_list += first + " "
                else:
                    author_list += first
            author_list += " " + author.last_names[0]
        else:
            author_list += " and " 
            for cc, first in enumerate(author.bibtex_first_names):
                if cc <len(author.bibtex_first_names)-1:
                    author_list += first + " "
                else:
                    author_list += first
            author_list += " " + author.last_names[0]
        author_list = author_list.replace("{","")
        author_list = author_list.replace("}","")
    #print(author_list)

# set up the citation for the publishing journal
    journal = bib_data.entries[entry].fields['journal']
    cit_journal = "<i>" + journal + "</i>"
    if 'volume' in bib_data.entries[entry].fields:
        cit_journal += ", " + bib_data.entries[entry].fields['volume']
    if 'pages' in bib_data.entries[entry].fields:
        cit_journal += ", " + bib_data.entries[entry].fields['pages']
    if 'doi' in bib_data.entries[entry].fields:
        cit_journal +=  ", doi:" + bib_data.entries[entry].fields['doi']
    cit_journal += "."
#    print(cit_journal)

    title    = html_escape(bib_data.entries[entry].fields['title'][1:-1])
    paper_url = bib_data.entries[entry].fields['url']
    citation = html_escape(author_list + ", " + str(year) + ": " + title + ", " + cit_journal)
    
    if 'abstract' in bib_data.entries[entry].fields: 
        excerpt = bib_data.entries[entry].fields['abstract']
    else: 
        excerpt = ""
        
## YAML variables
    
    md = "---\ntitle: \"" + title + '"\n'
    
    md += """collection: publications"""
    
    md += """\npermalink: /publication/""" + html_filename

    md += "\nyear: " + str(year) 

    md += "\nauthor: " + str(author_list) 

    md += "\nvenue: '" + journal + "'"
    
    md += "\nvenue_cit: '" + cit_journal + "'"
    
#    md += "\npaperurl: '" + paper_url + "'"
    
    md += "\ncitation: '" + citation + "'"
    
    md += "\n---"
    
    ## Markdown description for individual page
    excerpt = excerpt.replace("Abstract", "ABSTRACT:\n")
    if len(str(excerpt)) > 5:
        md += "\n" + html_escape(excerpt) + "\n"
    
    if len(str(paper_url)) > 5:
        md += "\nDownload paper: [here](" + download_filename + ") and [journal website](" + paper_url + ")\n" 
        
    md_filename = os.path.basename(md_filename)

    with open("../_publications/" + md_filename, 'w') as f:
        f.write(md)
    print(md)
    

