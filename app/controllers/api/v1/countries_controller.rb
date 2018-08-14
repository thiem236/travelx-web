class Api::V1::CountriesController < Api::ApiController

  # GET /countries
  swagger_controller :countries, 'Countries'

  swagger_api :list_by_trip_friend do
    Api::ApiController.add_common_params(self)
    summary "Returns country"
  end
  def list_by_trip_friend
    trip_schedules = Trip.
        where("trips.id IN (#{UserTrip.accepted.select(:trip_id).where(user_id: current_user.id).to_sql})").
        pluck(:trip_schedule).flatten
    respond_without_location trip_schedules.map{|c| c.slice("country","country_name")}.uniq {|e| e["country"] }
  end

  swagger_api :list_by_my_trip do
    Api::ApiController.add_common_params(self)
    summary "Returns country"
  end
  def list_by_my_trip
    trip_schedules = Trip.where(created_by: current_user.id).pluck(:trip_schedule).flatten
    countries =  trip_schedules.map{|c| c.slice("country","country_name")}.uniq {|e| e["country"] }
    respond_without_hash countries
  end

  swagger_api :list_by_trip_of_user do
    Api::ApiController.add_common_params(self)
    param :query , :user_id, :integer,"User id"
    summary "Returns country"
  end
  def list_by_trip_of_user
    user_id = params[:user_id] || current_user.id
    trip_schedules = Trip.where(created_by: user_id).pluck(:trip_schedule).flatten
    countries =  trip_schedules.map{|c| c.slice("country","country_name")}.uniq {|e| e["country"] }
    respond_without_hash countries
  end

  swagger_api :list_country_of_user do
    Api::ApiController.add_common_params(self)
    param :query , :user_id, :integer,"User id"
    summary "Returns country"
  end
  def list_country_of_user
    user_id = params[:user_id] || current_user.id
    trip_schedules = Trip.left_joins(:user_trips).where("created_by = ? or user_trips.user_id = ?",user_id,user_id).
        pluck(:trip_schedule).flatten
    countries =  trip_schedules.map{|c| c.slice("country","country_name")}.uniq {|e| e["country"] }
    respond_without_hash countries
  end


end
