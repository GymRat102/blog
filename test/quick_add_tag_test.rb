require "fileutils"
require "tmpdir"
require_relative "../scripts/quick_add_tag"

module AddTagAssertions
  module_function

  def equal(expected, actual)
    raise "Expected #{expected.inspect}, got #{actual.inspect}" unless expected == actual
  end

  def raises(error_class)
    yield
  rescue error_class
    return
  else
    raise "Expected #{error_class} to be raised"
  end
end

Dir.mktmpdir do |root|
  data_directory = File.join(root, "_data")
  FileUtils.mkdir_p(data_directory)
  File.write(
    File.join(data_directory, "quick_publish_tags.yml"),
    "- \"TIL\"\n- \"随想\"\n",
  )

  result = QuickAddTag.add(root:, tag: "  产品   设计  ")
  AddTagAssertions.equal({ tag: "产品 设计", added: true }, result)

  tags = YAML.safe_load_file(File.join(data_directory, "quick_publish_tags.yml"))
  AddTagAssertions.equal(["TIL", "随想", "产品 设计"], tags)

  result = QuickAddTag.add(root:, tag: "til")
  AddTagAssertions.equal({ tag: "TIL", added: false }, result)

  tags = YAML.safe_load_file(File.join(data_directory, "quick_publish_tags.yml"))
  AddTagAssertions.equal(["TIL", "随想", "产品 设计"], tags)
end

AddTagAssertions.raises(ArgumentError) do
  QuickAddTag.add(root: Dir.pwd, tag: " \n ")
end

AddTagAssertions.raises(ArgumentError) do
  QuickAddTag.add(root: Dir.pwd, tag: "a" * 65)
end

puts "quick_add_tag_test: OK"
