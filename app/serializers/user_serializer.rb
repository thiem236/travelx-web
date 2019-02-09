class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :email,
             :name,
             :country,
             :contact,
             :birthday,
             :profile_picture,
             :image_url,
             :uid,
             :verified,
             :allow_notification,
             :allow_tag_me,
             :receive_message,
             :fb_id,
             :cover_picture,
             :city

  def profile_picture
    Refile.attachment_url(object, :profile_picture )
  end

  def cover_picture
    Refile.attachment_url(object, :cover_picture )
  end

  def email
    object.email
  end
end
