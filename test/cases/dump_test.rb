require 'cases/helper'

class DumpTest < SeedSnapshot::TestCase
  def setup
    SeedSnapshot.clean
  end

  def test_exists_snapshot
    assert_equal SeedSnapshot.exists?, false
  end

  def test_dump
    SeedSnapshot.dump
    assert_equal SeedSnapshot.exists?, true
  end
end
