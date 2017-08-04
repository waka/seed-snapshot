class User < ActiveRecord::Base
  has_many :books
  has_many :rents, through: :books
end
