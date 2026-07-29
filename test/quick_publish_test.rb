require "tmpdir"
require_relative "../scripts/quick_publish"

module Assertions
  module_function

  def equal(expected, actual)
    raise "Expected #{expected.inspect}, got #{actual.inspect}" unless expected == actual
  end

  def includes(haystack, needle)
    raise "Expected output to include #{needle.inspect}" unless haystack.include?(needle)
  end

  def raises(error_class)
    begin
      yield
    rescue error_class
      return
    end

    raise "Expected #{error_class} to be raised"
  end
end

now = Time.iso8601("2026-07-26T15:32:08+08:00")

Dir.mktmpdir do |root|
  thought_path = QuickPublish.publish(
    root:,
    type: "thought",
    content: "A quick thought.\r\n\nhttps://example.com",
    tags: "TIL, 工具，TIL",
    images: <<~IMAGES,
      https://weijiand.me/uploads/one.png
      https://weijiand.me/uploads/two.png
    IMAGES
    now:,
  )

  Assertions.equal("_thoughts/2026-07-26-153208.md", thought_path)
  thought = File.read(File.join(root, thought_path))
  Assertions.includes(thought, "date: 2026-07-26 15:32:08 +0800")
  Assertions.includes(thought, "tags:\n  - \"TIL\"\n  - \"工具\"")
  Assertions.includes(
    thought,
    "images:\n" \
      "  - \"https://weijiand.me/uploads/one.png\"\n" \
      "  - \"https://weijiand.me/uploads/two.png\"",
  )
  Assertions.includes(thought, "A quick thought.\n\nhttps://example.com")

  post_path = QuickPublish.publish(
    root:,
    type: "post",
    title: "Designing Small Tools",
    tags: "Jekyll, 工具，Jekyll",
    content: "# Start\n\nWrite the smallest useful thing.",
    now:,
  )

  Assertions.equal("_posts/2026-07-26-designing-small-tools.md", post_path)
  post = File.read(File.join(root, post_path))
  Assertions.includes(post, 'title: "Designing Small Tools"')
  Assertions.includes(post, "  - \"Jekyll\"")
  Assertions.includes(post, "  - \"工具\"")
end

Dir.mktmpdir do |root|
  post_path = QuickPublish.publish(
    root:,
    type: "post",
    title: "一个中文标题",
    content: "正文",
    now:,
  )

  Assertions.equal("_posts/2026-07-26-post-153208.md", post_path)
end

Assertions.raises(ArgumentError) do
  QuickPublish.publish(root: Dir.pwd, type: "post", title: "", content: "正文", now:)
end

Assertions.raises(ArgumentError) do
  QuickPublish.publish(
    root: Dir.pwd,
    type: "thought",
    content: "正文",
    images: "not-a-url",
    now:,
  )
end

Assertions.raises(ArgumentError) do
  QuickPublish.publish(
    root: Dir.pwd,
    type: "thought",
    content: "正文",
    images: "https://example.com/image.png ||| 不再支持 alt",
    now:,
  )
end

puts "quick_publish_test: OK"
