class TripServices
  attr_accessor :trip_params, :current_user
  def initialize(params)
    @current_user = params[:current_user]
  end

  def create_new_trip(params)
    trip_params = permit_trip_params(params)
    trip = Trip.new(trip_params.merge(created_by: @current_user.id))
    ActiveRecord::Base.transaction do
      trip.save!
      User.where(id: params[:user_in_strip_ids]).each do |user|
        user.send_notification_invite_trip(trip, @current_user)
      end
    end
    # NoticeMessaveServices.new(trip_params[:user_in_strip_ids],{data: "#{@current_user.name} invite your trip"}).call
    trip
  end

  def update_new_trip(params)
    user_ids =
      if params[:user_in_strip_ids].present? && params[:user_in_strip_ids].is_a?(String)
        params[:user_in_strip_ids].split(",").map(&:to_i)
      else
        []
      end
    trip = Trip.find(params[:id])
    trip_params = permit_edit_trip_params(params)
    trip_params = trip_params.merge(trip_schedule: get_trip_schedules(trip,params)) if params[:trip_schedule].present?
    ActiveRecord::Base.transaction do
      trip.update!(trip_params)
      if user_ids
        User.where(id: (user_ids - trip.user_trips.pluck(:user_id))).each do |u|
          unless UserTrip.find_by(trip_id: trip.id, user_id: u.id )
            UserTrip.create(trip_id: trip.id, user_id: u.id,status: 'invited' )
            u.delay.send_notification_invite_trip(trip, @current_user)
            trip.update_activite
          end
        end
      end

    end

    trip
  end

  def get_trip_schedules(trip,params)
    old_schedule = trip.trip_schedule
    trip_schedules = []
    params[:trip_schedule].each_with_index do |trip,index|
      country_detail = old_schedule.select {|c| c['country'] == trip[:country]&.upcase}
      if country_detail.present?
        trip_schedules << country_detail.first
      else
        country_date = ISO3166::Country.find_country_by_alpha2(trip[:country])
        if country_date.present?
          trip_schedules << {
              country: trip[:country],
              city: trip[:city],
              start_date: params[:start_date].to_i,
              end_date: params[:end_date].to_i,
              days: 0,
              lat: country_date.latitude_dec,
              long: country_date.longitude_dec
          }
        end
      end
    end
    trip_schedules
  end

  def permit_trip_params(params)
    if params[:trip_schedule].is_a? Array
      params[:trip_schedule] = map_params_country(params)
    end
    if params[:user_in_strip_ids].is_a?String
      params[:user_in_strip_ids]=  params[:user_in_strip_ids].split(",").map(&:to_i)
    end
    params.permit(:name,
              :description,
              :cover_picture,
              :lat, :long,
              :start_date,
              :end_date,
                  {user_in_strip_ids: []},
              trip_schedule:  [:country, :city, :start_date, :end_date, :days, :lat, :long],
    )
  end

  def permit_edit_trip_params(params)
    params.permit(:name,
                  :start_date,
                  :end_date
    )
  end


  def map_params_country(params)
    params[:trip_schedule].map do |trip|
      if trip[:country]
        country = Geocoder.search("#{trip[:city]},#{trip[:country]}").first
      else
        country = Geocoder.search("#{trip[:lat]},#{trip[:long]}").first
      end
      if country.present?
        {
          country: country.country,
          city: country.city,
          start_date: params[:start_date].to_i,
          end_date: params[:end_date].to_i,
          days: 0,
          lat: country.latitude,
          long: country.longitude
        }
      else
        {
          country: trip[:country],
          city: trip[:city],
          start_date: 0,
          end_date: 0,
          days: 0,
          lat: 0,
          long: 0
        }
      end
    end
  end

  def get_image_friend
    friends = current_user.friends.select(:id).to_sql
    images = Attachment.joins(:trip).where("trips.created_by IN (#{friends})")
    images
  end

end