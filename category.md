---
layout: page
title: 分类
permalink: /category/
---
{% for category in site.categories %}[{{ category | first }}](#{{ category | first }}) {% endfor %}

{% for category in site.categories %}
<h2><a name="{{ category | first }}">#{{ category | first }}</a></h2>

{% for post in category.last %}[{{ post.title }}]({{ post.url }}) <span class="pull-right">{{ post.date | date_to_long_string }}</span>

{% endfor %}

{% endfor %}
