class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  def user_attributes=(attributes)
    self.user = User.find_or_create_by(attributes) unless attributes[:username].blank?
  end
end
