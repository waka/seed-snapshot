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

    lines = open(SeedSnapshot.configuration.current_version_path) { |f| f.readlines }
    assert lines.any? { |l| l.include?(User.table_name) }
    assert lines.any? { |l| l.include?(Book.table_name) }
    assert lines.any? { |l| l.include?(Rent.table_name) }
    assert lines.none? { |l| l.include?('ar_internal_metadata') }
    assert lines.none? { |l| l.include?('schema_migrations') }
  end
end
