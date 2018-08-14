class PostSerializer < ActiveModel::Serializer
  belongs_to :user
  attributes :id, :stamp_ids,:post_type, :title, :created_by, :created_at, :activity_type, :activity_id, :obj, :total_comment, :total_like

  def created_at
    object.created_at.to_i
  end

  def total_comment
    object.total_comment.to_i
  end

  def total_like
    object.total_like.to_i
  end
end
