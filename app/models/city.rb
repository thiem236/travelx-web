class City < ApplicationRecord
  include AcitvityConcern
  include NotificationConcern
  upsert_keys [:country, :name, :trip_id]
  attribute :name,:string, default: 'Unknown'
  attribute :country,:string, default: 'Unknown'
  attribute :show_count_comment, :boolean, default: false
  attribute :show_location, :boolean, default: false
  attribute :show_has_many, :boolean, default: false
  has_many :attachments, as: :able, dependent: :destroy
  has_many :comments, as: :comment_able,dependent: :destroy
  has_many :posts,as: :activity, dependent: :destroy
  belongs_to :trip
  belongs_to :user
  # validates_inclusion_of :country, :in => TZInfo::Country.all.map(&:code), :message => "Country code %s is not included in the list",allow_nil: true

  after_save :update_trip_schedule
  before_validation :set_defaut_country

  before_destroy :remove_comment_and_like_in_trip

  accepts_nested_attributes_for :attachments

  def show_all
    self.show_count_comment = true
    self.show_location = true
    self.show_has_many = true
  end
  def attachments
    super || attachments.new
  end
  def update_trip_schedule
    trip_schedule = trip.trip_schedule
    unless trip_schedule.select{ |c| c["country"] == country}.present?
      trip_schedule << {"country" =>  country}
    end
    countries = City.
        select("country, max(end_date) as end_date,min(start_date) as start_date").
        where(trip_id: trip_id).
        group(:country)
    trip_schedule.each.with_index do |schedule,index|
      new_country = countries.select{|c| c[:country] == schedule["country"]}.first
      if new_country.present?
        schedule[:start_date] = new_country[:start_date]
        schedule[:end_date] = new_country[:end_date].to_i >  new_country[:start_date].to_i ? new_country[:end_date] :  new_country[:end_date]+ (24*3600)
        days = ((new_country[:end_date] - new_country[:start_date]) /86400.to_f).round
        schedule[:days] =  days < 1  ? 1 : days

      end
      if saved_change_to_id? && schedule["country"] == country
        schedule[:start_date] = if schedule["start_date"].to_i < start_date && schedule["start_date"].to_i > 0
                                  schedule["start_date"].to_i
                                else
                                  start_date
                                end
        schedule[:end_date] =  schedule["end_date"].to_i < start_date ? start_date : schedule["end_date"].to_i
        days = (schedule["end_date"].to_f - schedule["start_date"].to_f) / 86400
        schedule[:days] = days <= 1 ? 1 : days.round
      end
      trip_schedule[index]  = schedule
    end
    trip.trip_schedule = trip_schedule
    trip.save!
  end

  def remove_comment_and_like_in_trip
    comment = trip.total_comment.to_i - comments.count
    like_num = trip.total_like.to_i - like.count
    trip.update_columns(total_comment: (comment > 0 ? comment : 0),total_like: (like_num > 0 ? like_num : 0))
  end

  def update_start_date_end_date
    city = self.attachments.select("max(uploaded_at) as max_date,min(uploaded_at) as min_date").to_a.first
    if city
      self.start_date = city['min_date']
      self.end_date = city['max_date']
      save
    end

  end

  def set_defaut_country
    self.country =
        begin
          ISO3166::Country.find_country_by_alpha2(country).alpha2
        rescue  => e
          'Unknown'
        end
  end

  def get_locations
    locations = attachments.select('place, place_type, place_id, min(lat) as lat, max(long) as long, min(uploaded_at) as start_date,max(uploaded_at) as end_date').group('place, place_type, place_id')
    locations.map do |item|
      {
          name: item['place'],
          type:item['place_type'],
          rate: 0,
          lat: item['lat'],
          long: item['long'],
          start_date: item['start_date'],
          end_date: item['end_date'],
          item_id: item['place_id']
      }
    end
  end
end
