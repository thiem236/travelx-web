class Comment < ApplicationRecord
  belongs_to :comment_able, polymorphic: true
  belongs_to :user
end
