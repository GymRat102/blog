---
layout: default
title: Thoughts
permalink: /thoughts/
---

<div class="thoughts-page">
  <div class="thought-list">
    {%- for thought in site.thoughts reversed -%}
      <article class="thought-item">
        <div class="thought-content">
          {{ thought.content }}
        </div>
        <time class="thought-date" datetime="{{ thought.date | date_to_xmlschema }}">
          {{ thought.date | date: "%Y-%m-%d %H:%M" }}
        </time>
      </article>
    {%- endfor -%}
  </div>
</div>

<script src="{{ "/assets/js/auto-link-urls.js" | relative_url }}" defer></script>
