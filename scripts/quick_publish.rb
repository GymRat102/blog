#!/usr/bin/env ruby

require "fileutils"
require "json"
require "time"

module QuickPublish
  SHANGHAI_OFFSET = 8 * 60 * 60

  module_function

  def publish(root:, type:, content:, title: nil, tags: nil, images: nil, slug: nil, now: Time.now)
    type = type.to_s.strip.downcase
    content = normalize_content(content)
    time = normalize_time(now)

    raise ArgumentError, "type must be thought or post" unless %w[thought post].include?(type)
    raise ArgumentError, "content must not be empty" if content.empty?

    type == "thought" \
      ? publish_thought(root:, content:, tags:, images:, time:, slug:) \
      : publish_post(root:, content:, title:, tags:, slug:, time:)
  end

  def publish_thought(root:, content:, tags:, images:, time:, slug:)
    suffix = slugify(slug)
    basename = time.strftime("%Y-%m-%d-%H%M%S")
    basename = "#{basename}-#{suffix}" unless suffix.empty?

    lines = [
      "---",
      "date: #{time.strftime("%Y-%m-%d %H:%M:%S %z")}",
    ]

    append_tags(lines, tags)
    append_images(lines, images)
    lines.concat(["---", "", content, ""])

    write_unique(
      root:,
      directory: "_thoughts",
      basename:,
      front_matter: lines.join("\n"),
      time:,
    )
  end

  def publish_post(root:, content:, title:, tags:, slug:, time:)
    title = title.to_s.strip
    raise ArgumentError, "title must not be empty for a post" if title.empty?

    normalized_slug = slugify(slug)
    normalized_slug = slugify(title) if normalized_slug.empty?
    normalized_slug = "post-#{time.strftime("%H%M%S")}" if normalized_slug.empty?
    basename = "#{time.strftime("%Y-%m-%d")}-#{normalized_slug}"

    lines = [
      "---",
      "layout: post",
      "title: #{JSON.generate(title)}",
      "date: #{time.strftime("%Y-%m-%d %H:%M:%S %z")}",
    ]

    append_tags(lines, tags)

    lines.concat(["---", "", content, ""])
    write_unique(root:, directory: "_posts", basename:, front_matter: lines.join("\n"), time:)
  end

  def normalize_content(content)
    content.to_s.gsub("\r\n", "\n").strip
  end

  def normalize_time(now)
    parsed = now.is_a?(Time) ? now : Time.iso8601(now.to_s)
    parsed.getlocal(SHANGHAI_OFFSET)
  end

  def parse_tags(tags)
    tags.to_s.split(/[,，\n]/).map(&:strip).reject(&:empty?).uniq
  end

  def append_tags(lines, tags)
    parsed_tags = parse_tags(tags)
    return if parsed_tags.empty?

    lines << "tags:"
    parsed_tags.each { |tag| lines << "  - #{JSON.generate(tag)}" }
  end

  def parse_images(images)
    return [] if images.nil?

    entries = images.is_a?(Array) ? images : images.to_s.lines
    entries.map(&:to_s).map(&:strip).reject(&:empty?).map.with_index do |source, index|
      if source.include?("|||")
        raise ArgumentError, "image #{index + 1} must contain only a URL"
      end

      unless source.match?(%r{\Ahttps?://}i)
        raise ArgumentError, "image #{index + 1} URL must start with http:// or https://"
      end

      source
    end
  end

  def append_images(lines, images)
    parsed_images = parse_images(images)
    return if parsed_images.empty?

    lines << "images:"
    parsed_images.each { |image| lines << "  - #{JSON.generate(image)}" }
  end

  def slugify(value)
    value.to_s
      .downcase
      .encode("ASCII", invalid: :replace, undef: :replace, replace: "")
      .gsub(/[^a-z0-9]+/, "-")
      .gsub(/\A-+|-+\z/, "")
  end

  def write_unique(root:, directory:, basename:, front_matter:, time:)
    target_directory = File.join(root, directory)
    FileUtils.mkdir_p(target_directory)

    candidates = [
      "#{basename}.md",
      "#{basename}-#{time.strftime("%H%M%S")}.md",
      "#{basename}-#{Process.pid}.md",
    ]

    candidates.each do |filename|
      path = File.join(target_directory, filename)

      begin
        File.open(path, File::WRONLY | File::CREAT | File::EXCL) do |file|
          file.write(front_matter)
        end
        return File.join(directory, filename)
      rescue Errno::EEXIST
        next
      end
    end

    raise "could not create a unique filename"
  end
end

if $PROGRAM_NAME == __FILE__
  path = QuickPublish.publish(
    root: ENV.fetch("GITHUB_WORKSPACE", Dir.pwd),
    type: ENV.fetch("QUICK_PUBLISH_TYPE"),
    content: ENV.fetch("QUICK_PUBLISH_CONTENT"),
    title: ENV["QUICK_PUBLISH_TITLE"],
    tags: ENV["QUICK_PUBLISH_TAGS"],
    images: ENV["QUICK_PUBLISH_IMAGES"],
    slug: ENV["QUICK_PUBLISH_SLUG"],
    now: ENV.fetch("QUICK_PUBLISH_NOW", Time.now.iso8601),
  )

  puts path
end
