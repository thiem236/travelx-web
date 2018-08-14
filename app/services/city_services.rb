class CityServices
  attr_accessor :trip_id, :country, :city_params, :current_user

  def initialize(city_params, current_user)
    @trip_id = city_params[:trip_id]
    @country = city_params[:country]
    @city_params = city_params
    @current_user = current_user
  end

  def get_country_detail_by_trip
    list_city = {}
    trip =Trip.includes(:cities).find_by(id: @trip_id)
    cities =trip.cities.order(created_at: :desc)
    locations = Location.joins(:city).select('cities.country, type, count(*) total_type').
        where(trip_id: @trip_id).group('cities.country, type').to_a
    trip.trip_schedule = trip.trip_schedule.sort { |x,y| x['start_date'] <=> y['start_date'] }
    trip.trip_schedule.map{|c| c['country']}.each do |code|
      map_result = {}
      city_list = cities.select {|city| city.country == code}.map{|c | CitySerializer.new(c,scope: @current_user)}
      location_country = locations.select{|lc| lc[:country] == code}
      location_country.each do |lc|
        map_result[lc[:type]] = lc[:total_type]
      end
      AppConstants::Location::TYPE.each do |c|
        map_result[c] ||= 0
      end
      map_result[:cities] = city_list
      list_city[code] = map_result
    end
    list_city
  end

  def get_city_detail_by_country
    trip =Trip.find_by(id: @trip_id)
    cities =trip.cities.where(country: @country).order('start_date asc ,created_at desc')
    cities.map{|c |
      c.show_location =  true
      CitySerializer.new(c, scope: @current_user)
    }

  end

end