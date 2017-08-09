require 'cases/helper'

class ManifestTest < SeedSnapshot::TestCase
  def setup
    m = SeedSnapshot.manifest
    m.appends(paths)
    m.save
  end

  def paths
    Dir.glob('./test/support/seeds/**/*')
  end

  def test_diff_if_not_added
    m1 = SeedSnapshot.manifest
    m1.appends(paths)

    assert_equal m1.diff?, false
  end

  # virtual diff
  def test_diff_if_added
    m1 = SeedSnapshot.manifest
    m1.appends(paths)

    m2 = SeedSnapshot.manifest
    m2.appends(paths)
    m2.appends(['./test/support/seeds.rb'])

    # has diff
    assert_equal m2.current.hash != m1.latest.hash, true
  end

  def test_save
  end
end
