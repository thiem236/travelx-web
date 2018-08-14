class CitySerializer < ActiveModel::Serializer
  has_many :comments, if: :show_has_many
  attributes :id, :name, :country, :lat, :long, :user_id, :end_date, :start_date, :created_at,:trip_id, :like_num, :comment_num
  attribute :total_hotel, if: :show_location
  attribute :total_restaurant, if: :show_location
  attribute :total_museum, if: :show_location
  attribute :total_bar, if: :show_location
  attribute :total_other, if: :show_location
  attribute :total_poi, if: :show_location
  attribute :locations, if: :show_location
  attribute :is_liked

  def show_location
    object.show_location
  end

  def locations
    object.get_locations
  end

  def is_liked
    if scope.present?
      object.like.include?(scope.id)
    else
      false
    end
  end

  def show_has_many
    object.show_has_many
  end
  def created_at
    object.decorate.created_at
  end

  def total_hotel
    object.attachments.select{|c| c.place_type == 'hotel'}.length
  end

  def total_restaurant
    object.attachments.select{|c| c.place_type == 'restaurant'}.length
  end

  def total_museum
    object.attachments.select{|c| c.place_type == 'museum'}.length
  end

  def total_poi
    object.attachments.select{|c| c.place_type == 'POI'}.length
  end

  def total_bar
    object.attachments.select{|c| c.place_type == 'bar'}.length
  end

  def total_other
    object.attachments.select{|c| c.place_type == 'other'}.length
  end

  def like_num
    object.like.length
  end

  def comment_num
    object.comments.length
  end

end