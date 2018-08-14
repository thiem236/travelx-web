class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content,:user_id, :user, :created_at


  def user
    UserSerializer.new(object.user)
  end

  def created_at
    object.created_at.to_i
  end
end
