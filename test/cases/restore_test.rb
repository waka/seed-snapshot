require 'cases/helper'

class RestoreTest < SeedSnapshot::TestCase
  def setup
    SeedSnapshot.clean

    create_models
    SeedSnapshot.dump(classes: [User, Book], ignore_classes: [Rent])
    destroy_models
  end

  def create_models
    user = User.create!
    book = Book.create!(user_id: user.id)
    Rent.create!(user_id: user.id, book_id: book.id)
    User.create!
  end

  def destroy_models
    User.destroy_all
    Book.destroy_all
    Rent.destroy_all
  end

  def test_restore
    assert_equal User.count, 0
    assert_equal Book.count, 0
    assert_equal Rent.count, 0

    SeedSnapshot.restore
    assert_equal User.count, 2
    assert_equal Book.count, 1
    assert_equal Rent.count, 0
  end
end
