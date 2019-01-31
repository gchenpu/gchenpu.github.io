#----------------------------------
#   how to maintain the website
#----------------------------------
# Steps to run the the website
1. run the script 'bundle exec jekyll serve'

The website is
http://127.0.0.1:4000/

# Steps to revise the website
modify the files in ./_pages

# Steps to update the publications for the website:
1. manually update 'publications.bib' in the folder 'markdown_generator'
2. start jupyter note: 'jupyter notebook --no-browser --port=8889'
3. run the script: 'publications.ipynb'

#----------------------------------
#          Markdown language
#----------------------------------

# Headings (\# \#\# \#\#\# etc.)

Alt Heading 1 (Headings need 4 = or -)
====

Alt Heading 2 (Headings need 4 = or -)
----

Normal text **bold** then *italic*.
Escape \* \` \< \_ \# \\ & more.

1. Order list
- Unorder list ( - or + )

code: `a === a`

> blockquote

URL: [Edditoria][1] | image: ![2][]

[1]: https://edditoria.blogspot.com
[2]: https://avatars0.githubusercontent.com/u/2234073?v=3&s=40

<!-- please comment -->

# Enjoy! :)
