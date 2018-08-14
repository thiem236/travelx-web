class PrivateStamp < Stamp
  belongs_to :user
  attachment :image, destroy: false
  # validates_uniqueness_of :user_id, scope: :country,message: "Stamp already exist"
  validates :country, presence: true

end