class Post < ActiveRecord::Base
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :comments
  has_many :users, -> { distinct }, through: :comments

  def categories_attributes=(attributes)
    category_name = attributes.values.first[:name]
    self.categories << Category.find_or_create_by(name: category_name) unless category_name.blank?
  end
end
