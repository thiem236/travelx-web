class Trip < ApplicationRecord
  include AcitvityConcern
  attribute :show_belong, :boolean, default: false
  attribute :show_last_image, :boolean, default: false
  attribute :show_images, :boolean, default: false
  attribute :show_user_join_trip, :boolean, default: false

  extend Enumerize
  belongs_to :user, foreign_key: :created_by
  has_many :posts,as: :activity, dependent: :destroy
  has_many :user_trips, dependent: :destroy
  has_many :user_in_strips, source: :user, through: :user_trips
  has_many :attachments,dependent: :delete_all
  has_many :locations, dependent: :delete_all
  has_many :cities, dependent: :delete_all
  validates :end_date, presence: true
  validates :start_date, presence: true

  # before_save :set_country_code
  before_save :check_schedule_when_update
  before_destroy :delete_noti



  enumerize :status, in: AppConstants::Trip::STATUS, predicates: true, scope: true

  def update_activite
    Post.where(trip_id: id).each do |post|
      activity_service = ActivityServices.new(
          {activity_id: post.activity_id, activity_type: post.post_type},post.user
      )
      activity_service.update_activity(post)
    end
  end

  # def set_country_code
  #   trip_schedule.compact.each do |s|
  #     country = ISO3166::Country.find_country_by_alpha2(s["country"].strip) rescue nil
  #     if country.present?
  #       s["country_name"] = TZInfo::Country.get(s["country"].strip).name
  #       s["lat"] =  country.latitude_dec
  #       s["long"] =  country.longitude_dec
  #     else
  #       s["country_name"] = 'Unknown'
  #       s["country"] = 'Unknown'
  #       s["lat"] =  0.0
  #       s["long"] =   0.0
  #     end
  #
  #   end
  #
  # end

  def check_schedule_when_update
    if trip_schedule_changed? && !new_record?
      country_diff = trip_schedule_change[0].map{|c| c['country']} - trip_schedule_change[1].map{|c| c['country']}
      City.where(country: country_diff).destroy_all
    end
  end

  def update_trip_schedule
    countries = City.
        select("country, max(end_date) as end_date,min(start_date) as start_date").
        where(trip_id: id).
        group(:country)
    trip_schedule.each.with_index do |schedule,index|
      new_country = countries.select{|c| c[:country] == schedule["country"]}.first
      if new_country.present?
        schedule[:start_date] = new_country[:start_date]
        schedule[:end_date] = new_country[:end_date].to_i >  new_country[:start_date].to_i ? new_country[:end_date] :  new_country[:end_date]+ (24*3600)
        days = ((new_country[:end_date] - new_country[:start_date]) /86400.to_f).round
        schedule[:days] =  days < 1  ? 1 : days
      else
        schedule[:days] = 0

      end
      trip_schedule[index]  = schedule
    end
    countries.each do |country|
      puts "====trip_schedule#{country[:country]}"
      new_country = trip_schedule.compact.select{|c| c["country"] == country[:country]}.first
      unless new_country
        schedule = {}
        schedule["country"] = country[:country]
        schedule[:start_date] = country[:start_date]
        schedule[:end_date] = country[:end_date].to_i >  country[:start_date].to_i ? country[:end_date] :  country[:end_date]+ (24*3600)
        days = ((country[:end_date] - country[:start_date]) /86400.to_f).round
        schedule[:days] =  days < 1  ? 1 : days
        trip_schedule << schedule
      end
    end
    puts trip_schedule
    save!
  end

  def delete_noti
    Notification.where(able_id: id,able_type: 'Trip').destroy_all
  end

end
