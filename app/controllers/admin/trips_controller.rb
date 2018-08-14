module Admin
  class TripsController < Admin::ApplicationController
    before_action :convert_time, only: [:create, :update]
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Trip.
    #     page(params[:page]).
    #     per(10)
    # end

    def show
      @user_trips = requested_resource.user_trips.includes(:user)
      @friends = requested_resource.user.friends.pluck(:name, :id)
      super
    end

    def remove_user
      trip = Trip.find(params[:id])
      UserTrip.find_by(trip_id: trip.id,user_id: params[:user_id]).destroy
      redirect_back(fallback_location: admin_trips_path)
    end

    def add_user
      @trip = Trip.find(params[:id])
      @ut = UserTrip.create(trip_id: @trip.id,user_id: params[:user_id]) unless  UserTrip.find_by(trip_id: @trip.id,user_id: params[:user_id])
      render layout: false
    end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Trip.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def convert_time
     params[:trip][:start_date] =  DateTime.strptime(params[:trip][:start_date], '%Y-%m-%d').to_i if params[:trip][:start_date].present?
     params[:trip][:end_date] =  DateTime.strptime(params[:trip][:end_date], '%Y-%m-%d').to_i if params[:trip][:end_date].present?
    end
  end
end
