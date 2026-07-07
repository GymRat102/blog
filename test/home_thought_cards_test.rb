require "minitest/autorun"

class HomeThoughtCardsTest < Minitest::Test
  CSS = File.read(File.expand_path("../assets/main.scss", __dir__))
  HOME_LAYOUT = File.read(File.expand_path("../_layouts/home.html", __dir__))

  def test_recent_thought_cards_are_compact_but_readable
    card_rules = css_block(".home-thought-card")
    content_rules = css_block(".home-thought-content")
    more_rules = css_block(".home-thought-more-link")
    mobile_card_rules = css_block(".home-thought-card", within_media: "max-width: 640px")
    mobile_content_rules = css_block(".home-thought-content", within_media: "max-width: 640px")

    assert_includes card_rules, "flex: 0 0 18rem;"
    assert_includes card_rules, "min-height: 14.75rem;"
    assert_includes content_rules, "-webkit-line-clamp: 7;"
    assert_includes more_rules, "min-height: 14.75rem;"
    assert_includes mobile_card_rules, "min-width: 14.5rem;"
    assert_includes mobile_card_rules, "min-height: 13.5rem;"
    assert_includes mobile_content_rules, "-webkit-line-clamp: 6;"
  end

  def test_each_recent_thought_card_has_a_more_hint
    assert_includes HOME_LAYOUT, "home-thought-card-meta"
    assert_includes HOME_LAYOUT, "home-thought-read-more"
    assert_includes HOME_LAYOUT, "More"
  end

  def test_recent_thought_card_shows_date_and_time
    assert_includes HOME_LAYOUT, 'date: "%Y-%m-%d %H:%M"'
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
