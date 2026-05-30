---
layout: default
title: Tags
permalink: /tags/
---

<div class="tags-page">
  <h1 class="page-kicker" id="tag-page-title">Tags</h1>

  <div class="tag-index">
    {%- assign sorted_tags = site.tags | sort -%}
    {%- for tag in sorted_tags -%}
      {%- assign tag_name = tag[0] -%}
      {%- assign posts = tag[1] -%}
      <section class="tag-section" id="tag-{{ tag_name | uri_escape }}" data-tag="{{ tag_name | escape }}">
        <h2 class="tag-section-title">{{ tag_name | escape }}</h2>
        <div class="archive-items">
          {%- for post in posts -%}
            <article class="archive-item">
              <div class="archive-item-main">
                <a class="archive-title" href="{{ post.url | relative_url }}">{{ post.title | escape }}</a>
                <span class="archive-rule" aria-hidden="true"></span>
                <time class="archive-date" datetime="{{ post.date | date_to_xmlschema }}">
                  {{ post.date | date: "%Y-%m-%d" }}
                </time>
              </div>
            </article>
          {%- endfor -%}
        </div>
      </section>
    {%- endfor -%}
  </div>
</div>

<script src="{{ "/assets/js/tag-filter.js" | relative_url }}" defer></script>
