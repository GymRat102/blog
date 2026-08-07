---
layout: default
title: Tags
permalink: /tags/
---

<div class="tags-page">
  <h1 class="page-kicker" id="tag-page-title">Tags</h1>

  <div class="tag-index">
    {%- assign tagged_items = site.posts | concat: site.thoughts | sort: "date" | reverse -%}
    {%- assign sorted_tags = tagged_items | map: "tags" | compact | join: "," | split: "," | uniq | sort -%}
    {%- for tag_name in sorted_tags -%}
      <section class="tag-section" id="tag-{{ tag_name | uri_escape }}" data-tag="{{ tag_name | escape }}">
        <h2 class="tag-section-title">{{ tag_name | escape }}</h2>
        <div class="archive-items">
          {%- for item in tagged_items -%}
            {%- if item.tags contains tag_name -%}
              <article class="archive-item{% if item.url contains "/thoughts/" %} archive-item-thought{% endif %}">
                <div class="archive-item-main">
                  <span class="tagged-item-label">
                    <span class="content-type-badge{% if item.url contains "/thoughts/" %} content-type-thought{% else %} content-type-blog{% endif %}">
                      {%- if item.url contains "/thoughts/" -%}Thought{%- else -%}Blog{%- endif -%}
                    </span>
                    <a class="archive-title" href="{{ item.url | relative_url }}">
                      {%- if item.url contains "/thoughts/" -%}
                        {{ item.content | strip_html | strip_newlines | truncate: 72 | escape }}
                      {%- else -%}
                        {{ item.title | escape }}
                      {%- endif -%}
                    </a>
                  </span>
                  <span class="archive-rule" aria-hidden="true"></span>
                  <time class="archive-date" datetime="{{ item.date | date_to_xmlschema }}">
                    {{ item.date | date: "%Y-%m-%d" }}
                  </time>
                </div>
              </article>
            {%- endif -%}
          {%- endfor -%}
        </div>
      </section>
    {%- endfor -%}
  </div>
</div>

<script src="{{ "/assets/js/tag-filter.js" | relative_url }}" defer></script>
