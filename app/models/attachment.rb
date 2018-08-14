class Attachment < ApplicationRecord

  include AcitvityConcern
  include NotificationConcern
  attribute :show_count_comment, :boolean, default: false
  attribute :show_location, :boolean, default: false
  attribute :show_has_many, :boolean, default: false
  attribute :show_belong, :boolean, default: true

  self.inheritance_column = nil
  extend Enumerize
  belongs_to :able, polymorphic: true
  has_many :comments, as: :comment_able
  has_many :posts,as: :activity, dependent: :destroy
  belongs_to :trip,optional: true
  attachment :file
  enumerize :type, in: AppConstants::Attachment::TYPE, predicates: true, scope: true
  after_save :clear_association
  after_destroy :clear_data_when_destroy
  after_destroy :remove_comment_and_like_in_trip
  before_save :set_default_value

  scope :images, -> {with_type(:picture)}


  default_value_for :type, AppConstants::Attachment::TYPE.first

  def set_default_value
    self.place ||= 'unknown'
    self.place_type ||= 'unknown'
    unless place_id.present?
      self.place_type = 'other'
    end
  end

  def clear_association
    if !saved_change_to_id? && able_type=='City' && saved_change_to_able_id?
      @city = City.find_by(id:saved_change_to_able_id[0])
      if @city.present? && @city.attachments.where.not(id: id).count == 0
        @city.destroy!
      end
    end
  end

  def clear_data_when_destroy
    if able_type=='City'
      @city = City.find_by(id: able_id)
      if @city.present? && @city.attachments.where.not(id: id).count == 0
        @city.destroy!
      end
    end
  end

  def remove_comment_and_like_in_trip
    trip.update_columns(total_comment: (trip.total_comment.to_i - comments.count.to_i),total_like: (trip.total_like.to_i - likes.count.to_i)) if trip.present?
  end

  def location
    {
        name: place,
        type: place_type,
        rate: 0,
        lat: lat,
        long: long,
        # start_date: start_date,
        # end_date: end_date,
        item_id: place_id
    }
  end

end
