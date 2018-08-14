class StampSerializer < ActiveModel::Serializer
  attributes :id, :country, :created_at,:uploaded_at

  def created_at
    object.created_at.to_i
  end

  def image_url
    Refile.attachment_url(object, :image )
  end


end