---
permalink: /
title: "About"
excerpt: "About me"
author_profile: true
redirect_from: 
  - /about/
  - /about.html
---

{% include base_path %}

The focus of my research group is the fundamental dynamics in atmospheric circulation and chemical transport.  Through a combination of theory and numerical modeling, we develop toolboxes to understand the global circulation of the atmosphere, from tropical Hadley cell circulations to extratropical storm systems, from tropospheric extreme weather to stratospheric polar vortex breakdown events, and from transport of water vapor to stratosphere-troposphere exchange of ozone.  These processes are instrumental to our understanding of weather extremes (e.g. winter blizzards or heat waves), hydrological extremes (e.g., drought or flooding), or extreme air pollution. Our research can be categorized in two interrelated themes. 
* Global atmospheric circulation and regional weather extremes
* Transport of atmospheric moisture and chemical species

For example, transport and mixing near the tropopause (~10km above the ground) can be illustrated in the animantion of Ertel's Potential Vorticity (left) and O3 mixing ratio (right):
![](/images/PV_O3.gif)

Recent Publications
======
<ul>
    {% assign sorted = (site.publications | sort: 'date') | reverse %}
    {% for post in sorted limit:5 %}
        {% include archive-single-publication.html %}
    {% endfor %}
</ul>
  
