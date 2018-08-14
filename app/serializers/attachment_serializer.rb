class AttachmentSerializer < ActiveModel::Serializer
  has_many :comments, if: :show_has_many
  belongs_to :trip, if: :show_belong
  attributes :id, :able_id, :able_type, :file_url, :created_at, :like_num, :comment_num, :uploaded_at, :caption,:trip_id, :upload_by,:location
  attribute :is_liked


  def file_url
    Refile.attachment_url(object, :file )
  end

  def location
    object.location
  end

  def show_has_many
    object.show_has_many
  end

  def show_belong
    object.show_belong
  end

  def is_liked
    if scope.present?
      object.likes.include?(scope.id)
    else
      false
    end
  end


  def created_at
    object.decorate.created_at
  end

  def like_num
    object.likes.length
  end

  def comment_num
    object.comments.length
  end
end