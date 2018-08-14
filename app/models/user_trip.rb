class UserTrip < ApplicationRecord
  extend Enumerize
  belongs_to :trip
  belongs_to :user

  before_create :init_field

  enumerize :status, in: AppConstants::UserTrip::STATUS, predicates: true, scope: true
  enumerize :user_type, in: AppConstants::UserTrip::USER_TYPE, predicates: true, scope: true
  scope :accepted, ->{with_status(:accepted)}
  scope :invited, ->{with_status(:invited)}

  def init_field
    self.status = "invited" unless status.present?
    self.user_type = "member" unless user_type.present?
  end

  def accept_trip
    self.status = 'accepted'
    save!
    trip.user.notification_accepted_trip(trip,user)
  end

  def ignored_trip
    self.status = 'ignored'
    save!
    trip.user.notification_ignored_trip(trip,user)
  end


end
