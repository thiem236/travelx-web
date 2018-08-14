require 'active_support/concern'
module AcitvityConcern
  extend ActiveSupport::Concern
  included do
    after_save :update_acivity
  end

  def update_acivity
    unless new_record?
      case self.class.name
        when 'Trip'
          update_post(self.user)
        when 'Attachment'
          update_post(self.trip.user)
        when 'City'
          update_post(self.user)
      end
    end

  end

  def update_post( user)
    self.posts.each do |post|
      activity_service = ActivityServices.new(
          {activity_id: post.activity_id, activity_type: post.post_type},user
      )
      activity_service.update_activity(post)
    end

  end
end
