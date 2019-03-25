class Friendship < ApplicationRecord
  extend Enumerize
  belongs_to :friend , class_name: 'User', foreign_key: :current_user_id
end
