---
layout: page
title: 存档
permalink: /archive/
---
{% assign post_year1 = "" %}
{% for post in site.posts %}{% capture post_year2 %}{{ post.date | date: '%Y' }}{% endcapture %}{% if post_year1 != post_year2 %}{% assign post_year1 = post_year2 %}

## {{ post_year1 }}

{% endif %}
[{{ post.title }}]({{ post.url }}) <span class="pull-right">{{ post.date | date_to_long_string }}</span>

{% endfor %}
