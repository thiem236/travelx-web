class TripSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :trip_schedule, :created_by, :start_date, :end_date, :created_at, :city
  belongs_to :user, if: :show_belong?
  attribute :last_picture, if: :show_last_image?
  attribute :user_join_trip, if: :show_user_join_trip?

  def start_date
    object.start_date
  end

  def show_user_join_trip?
    object.show_user_join_trip
  end

  def show_last_image?
    object.show_last_image
  end

  def show_images?
    object.show_images = true
  end

  def last_picture
    image = object.attachments.images.order(uploaded_at: :desc, created_at: :desc).first
    if image.present?
      image.show_belong = false
    end
    AttachmentSerializer.new(image, scope: scope[:current_user])
  end

  def end_date
    object.end_date
  end

  def created_at
    object.decorate.created_at
  end

  def user_join_trip

    object.user_in_strips.where("user_trips.status = ?",'accepted').map{|u| UserSerializer.new(u)}
  end

  def show_belong?
    object.show_belong
  end

end