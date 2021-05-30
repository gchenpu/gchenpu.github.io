# Note on how to maintain academic pages
## Install ruby to maintain academic pages

https://jekyllrb.com/docs/

* Install all prerequisites and follow the guide for Ubuntu

  https://jekyllrb.com/docs/installation/

* install ruby-dev, bundler, and nodejs

```bash
sudo apt install ruby-dev ruby-bundler nodejs
```

* cd to the website directory
* Run `bundle clean` to clean up the directory (no need to run `--force`)

* Run `bundle install` to install ruby dependencies. If you get errors, delete Gemfile.lock and try again. 

## How to view the the website

* cd to the website directory and run the script

```
bundle exec jekyll serve
```

* The website is viewed at the url: http://127.0.0.1:4000/

## How to add a new page to the website
* add the new page to `./_data/navigation.yml`

## How to revise the website pages

modify the files in `./_pages`
*Group*: group.html
*Publication*: see the instructions below
*CV*: cv.md
*Code*: code.md

## Steps to update the publications for the website:

* manually update `publications.bib` in the folder `markdown_generator` (add Abstract to previous entries if time permits)

* install `pybtex` package, https://pybtex.org/

  ```
  pip install pybtex
  ```

* start jupyter notebook:

  ```
  jupyter notebook --no-browser --port=8889
  ```
  
  Edit the script in  `publications.ipynb`

