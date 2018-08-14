module AppConstants
  module Trip
    STATUS = %w(pending accept canceled)
  end

  module FriendShip
    STATUS = %w(
      invited
      accepted
      canceled
    )
  end

  module UserTrip
    STATUS = %w(
      invited
      accepted
      ignored
    )
    USER_TYPE = %w(
      member
      owner
    )
  end

  module Location
    TYPE = %w(
      hotel
      restaurant
      museum
      bar
      other
      point_of_interest
    )
  end

  module Attachment
    TYPE = %w(
      picture
      passport
    )
  end

  module Notification
    STATUS = %w(
      sending
      read
    )
    NOTIFICATION_TYPE = %w(
      invite_trip
      reject_invite_trip
      accept_trip
      trip_rejected
      trip_accepted
      commented
      liked
      accepted_friend
      invited_friend
    )
  end
end