---
layout: archive
title: ""
permalink: /publications/
author_profile: true
---

{% include base_path %}

Publications
======
<ol>
    {% for post in site.publications reversed %}
        {% include archive-single-publication.html %}
    {% endfor %}
</ol>
