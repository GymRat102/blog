require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class ArchivePagesTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_built_archives_show_bits_and_blog_without_legacy_thoughts
    Dir.mktmpdir do |workspace|
      source = File.join(workspace, "source")
      destination = File.join(workspace, "site")
      FileUtils.mkdir_p(source)
      %w[_config.yml _includes _layouts _posts _thoughts assets bits.markdown
         blog.markdown index.markdown tags.markdown].each do |path|
        FileUtils.cp_r(File.join(ROOT, path), source)
      end

      bits = File.join(source, "_bits")
      FileUtils.mkdir_p(bits)

      build_site(source, destination)
      empty_home = File.read(File.join(destination, "index.html"))
      empty_archive = File.read(File.join(destination, "bits/index.html"))
      assert_includes empty_home, '<p class="archive-empty">No writing yet</p>'
      assert_includes empty_archive, '<p class="archive-empty">No writing yet</p>'
      refute_includes empty_home, "More Bits"

      1.upto(6) do |number|
        File.write(File.join(bits, "entry-#{number}.md"), <<~MARKDOWN)
          ---
          title: Archive fixture #{number}
          date: 2020-01-0#{number} 12:00:00 +0800
          tags: [Fixture]
          ---
          Fixture body.
        MARKDOWN

        if number == 5
          build_site(source, destination)
          full_home = File.read(File.join(destination, "index.html"))
          assert_equal %w[5 4 3 2 1], full_home.scan(/>Archive fixture (\d)<\/a>/).flatten
          refute_includes full_home, "More Bits"
          refute_includes full_home, "No writing yet"
        end
      end

      build_site(source, destination)

      home = File.read(File.join(destination, "index.html"))
      bits_archive = File.read(File.join(destination, "bits/index.html"))
      blog_archive = File.read(File.join(destination, "blog/index.html"))
      bit_detail = File.read(File.join(destination, "bits/entry-6/index.html"))
      tags = File.read(File.join(destination, "tags/index.html"))

      assert_equal %w[6 5 4 3 2], home.scan(/>Archive fixture (\d)<\/a>/).flatten
      assert_equal %w[6 5 4 3 2 1], bits_archive.scan(/>Archive fixture (\d)<\/a>/).flatten
      assert_includes home, 'href="/preview/bits/">More Bits</a>'
      assert_includes home, 'href="/preview/bits/">Bits</a>'
      assert_includes home, 'href="/preview/blog/">Blogs</a>'
      assert_includes home, 'id="home-blog-heading" class="archive-section-heading">Blogs</h2>'
      assert_includes bits_archive, 'href="/preview/bits/" aria-current="page">Bits</a>'
      assert_includes blog_archive, 'href="/preview/blog/" aria-current="page">Blogs</a>'
      assert_includes blog_archive, '<h1 class="archive-section-heading">Blogs</h1>'
      assert_equal Dir.glob(File.join(source, "_posts/*.md")).size, blog_archive.scan('class="archive-title"').size
      assert_includes bit_detail, 'class="post-title p-name"'
      assert_includes bit_detail, 'href="/preview/tags/?tag=Fixture"'
      assert_includes home, 'href="/preview/tags/?tag=Fixture" data-count="6"'
      assert_includes tags, 'href="/preview/bits/entry-1/"'
      refute_includes home, "/thoughts/"
      refute_includes tags, "/thoughts/"
      refute File.exist?(File.join(destination, "thoughts"))
      refute File.exist?(File.join(destination, "_thoughts"))
    end
  end

  private

  def build_site(source, destination)
    output, status = Open3.capture2e(
      "bundle", "exec", "jekyll", "build", "--disable-disk-cache",
      "--source", source, "--destination", destination, "--baseurl", "/preview",
      chdir: ROOT,
    )
    assert status.success?, output
  end
end
