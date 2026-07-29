#!/usr/bin/env ruby

require "json"
require "yaml"

module QuickAddTag
  TAGS_PATH = "_data/quick_publish_tags.yml"
  MAX_LENGTH = 64

  module_function

  def add(root:, tag:)
    normalized_tag = normalize(tag)
    raise ArgumentError, "tag must not be empty" if normalized_tag.empty?
    raise ArgumentError, "tag must be #{MAX_LENGTH} characters or fewer" if normalized_tag.length > MAX_LENGTH

    path = File.join(root, TAGS_PATH)
    tags = load_tags(path)
    existing_tag = tags.find { |item| item.casecmp?(normalized_tag) }

    return { tag: existing_tag, added: false } if existing_tag

    tags << normalized_tag
    File.write(path, tags.map { |item| "- #{JSON.generate(item)}" }.join("\n") + "\n")

    { tag: normalized_tag, added: true }
  end

  def normalize(tag)
    tag.to_s.strip.gsub(/[[:space:]]+/, " ")
  end

  def load_tags(path)
    parsed = YAML.safe_load_file(path, permitted_classes: [], aliases: false)
    raise "tag config must be a list of strings" unless parsed.is_a?(Array) && parsed.all?(String)

    parsed
  end
end

if $PROGRAM_NAME == __FILE__
  result = QuickAddTag.add(
    root: ENV.fetch("GITHUB_WORKSPACE", Dir.pwd),
    tag: ENV.fetch("QUICK_ADD_TAG"),
  )

  puts JSON.generate(result)
end
