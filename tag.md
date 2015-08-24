---
layout: page
title: 标签
permalink: /tag/
---
{% for tag in site.tags %}[{{ tag | first }}](#{{ tag | first }}) {% endfor %}

{% for tag in site.tags %}
<h2><a name="{{ tag | first }}"># {{ tag | first }}</a></h2>

{% for post in tag.last %}
[{{ post.title }}]({{ post.url }}) <span class="pull-right">{{ post.date | date_to_string }}</span>
{% endfor %}{% endfor %}
