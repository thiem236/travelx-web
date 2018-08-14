class Post < ApplicationRecord

  belongs_to :user, foreign_key: :created_by
  belongs_to :activity, polymorphic: true, optional: true
end
