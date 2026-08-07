require "minitest/autorun"

class HomeThoughtCardsTest < Minitest::Test
  CSS = File.read(File.expand_path("../assets/main.scss", __dir__))
  HOME_LAYOUT = File.read(File.expand_path("../_layouts/home.html", __dir__))
  TAGS_PAGE = File.read(File.expand_path("../tags.markdown", __dir__))
  TAG_LIST = File.read(File.expand_path("../_includes/tag-list.html", __dir__))
  GALLERY_JS = File.read(File.expand_path("../assets/js/thought-gallery.js", __dir__))

  def test_recent_thought_cards_are_compact_but_readable
    card_rules = css_block(".home-thought-card")
    content_rules = css_block(".home-thought-content")
    more_rules = css_block(".home-thought-more-link")
    mobile_card_rules = css_block(".home-thought-card", within_media: "max-width: 640px")
    mobile_content_rules = css_block(".home-thought-content", within_media: "max-width: 640px")

    assert_includes card_rules, "flex: 0 0 18rem;"
    assert_includes card_rules, "height: 15.5rem;"
    assert_includes card_rules, "min-height: 15.5rem;"
    assert_includes card_rules, "grid-template-rows: auto minmax(0, 1fr) auto;"
    assert_includes content_rules, "overflow: hidden;"
    assert_includes more_rules, "min-height: 15.5rem;"
    assert_includes mobile_card_rules, "min-width: min(84vw, 20rem);"
    assert_includes mobile_card_rules, "height: 14.25rem;"
    assert_includes mobile_card_rules, "min-height: 14.25rem;"
    assert_includes mobile_content_rules, "line-height: 1.6;"
  end

  def test_each_recent_thought_card_has_a_more_hint
    assert_includes HOME_LAYOUT, "home-thought-card-meta"
    assert_includes HOME_LAYOUT, "home-thought-read-more"
    assert_includes HOME_LAYOUT, "More"
  end

  def test_recent_thoughts_have_a_visible_archive_heading
    assert_includes HOME_LAYOUT, 'class="archive-section-heading home-thoughts-heading">Thoughts</h2>'
    refute_includes HOME_LAYOUT, 'id="home-thoughts-heading" class="screen-reader-text"'
  end

  def test_blog_archive_has_a_counterpart_heading
    assert_includes HOME_LAYOUT, '<h2 id="home-blog-heading" class="archive-section-heading">Blog</h2>'
    refute_includes HOME_LAYOUT, "assign current_year"
    refute_includes HOME_LAYOUT, "archive-year"
    refute_includes HOME_LAYOUT, 'id="year-'
  end

  def test_recent_thought_card_shows_date_and_time
    assert_includes HOME_LAYOUT, 'date: "%Y-%m-%d %H:%M"'
  end

  def test_thought_tags_link_to_the_combined_tag_page
    refute_includes HOME_LAYOUT, "tags=thought.tags static=true"
    assert_includes TAG_LIST, 'href="{{ "/tags/" | relative_url }}?tag={{ tag | uri_escape }}"'
    assert_includes TAGS_PAGE, 'site.posts | concat: site.thoughts'
    assert_includes TAGS_PAGE, 'item.tags contains tag_name'
    assert_includes TAGS_PAGE, 'item.url contains "/thoughts/"'
    assert_includes TAGS_PAGE, "content-type-thought"
    assert_includes TAGS_PAGE, "content-type-blog"
    assert_includes TAGS_PAGE, "Thought"
    assert_includes TAGS_PAGE, "Blog"
  end

  def test_tagged_items_keep_the_date_aligned_on_mobile
    mobile_tagged_item_rules = css_block(".tags-page .archive-item-main", within_media: "max-width: 640px")

    assert_includes mobile_tagged_item_rules, "display: grid;"
    assert_includes mobile_tagged_item_rules, "grid-template-columns: minmax(0, 1fr) auto;"
    assert_includes mobile_tagged_item_rules, "align-items: start;"
  end

  def test_thought_images_render_as_a_bottom_right_gallery
    image_meta_rules = css_block(".home-thought-card.has-image .home-thought-card-meta")
    gallery_rules = css_block(".home-thought-gallery")
    thumbnail_rules = css_block(".home-thought-thumbnail-button")

    assert_includes HOME_LAYOUT, "assign thought_image_count = thought.images.size"
    assert_includes HOME_LAYOUT, "{% if thought_image_count > 0 %} has-image{% endif %}"
    assert_includes HOME_LAYOUT, "for gallery_image in thought.images"
    assert_includes HOME_LAYOUT, 'gallery_image_src contains "://"'
    assert_includes HOME_LAYOUT, "assign gallery_image_url = gallery_image_src"
    assert_includes HOME_LAYOUT, 'data-gallery-src="{{ gallery_image_url }}"'
    assert_includes HOME_LAYOUT, "home-thought-gallery-count"
    assert_includes image_meta_rules, "justify-content: space-between;"
    assert_includes gallery_rules, "grid-template-columns: repeat(2, minmax(0, 1fr));"
    assert_includes gallery_rules, "margin: 0 0 0 auto;"
    assert_includes thumbnail_rules, "cursor: zoom-in;"
  end

  def test_gallery_opens_a_swipeable_lightbox
    track_rules = css_block(".thought-lightbox-track")

    assert_includes HOME_LAYOUT, 'id="thought-lightbox"'
    assert_includes HOME_LAYOUT, "thought-lightbox-prev"
    assert_includes HOME_LAYOUT, "thought-lightbox-next"
    assert_includes track_rules, "overflow-x: auto;"
    assert_includes track_rules, "scroll-snap-type: x mandatory;"
    assert_includes GALLERY_JS, "dialog.showModal()"
    assert_includes GALLERY_JS, 'event.key === "ArrowLeft"'
    assert_includes GALLERY_JS, 'event.key === "ArrowRight"'
  end

  private

  def css_block(selector, within_media: nil)
    source = if within_media
      CSS.match(/@media screen and \((?<media>#{Regexp.escape(within_media)})\)\s*\{(?<rules>.*)\n\}/m)[:rules]
    else
      CSS
    end

    source.match(/#{Regexp.escape(selector)}\s*\{(?<rules>.*?)\n\s*\}/m)[:rules]
  end
end
