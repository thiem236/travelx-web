class Api::V1::TripsController < Api::ApiController
  include TripHelper
  swagger_controller :trips, "Trip controller"
  # GET /api/v1/trips
  swagger_api :index do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :query, :page, :string, :optional, "Default 1 "
    param :query, :per_page, :string, :optional, "Default 20 "
    param :query, :show_image, :string, :optional, "1 if show image"
    param :query, :country, :string, :optional, "Search for country code"
    param :query, :user_id, :integer, :optional, "Get trip from anthoer user"
    param :query, :time, :string, :optional, "time"
  end

  def index
    begin
      page = params[:page] || 1
      per_page = params[:per_page] || 5
      if params[:user_id].present?
        @trips = Trip.where(created_by: params[:user_id]).
            or(Trip.where(id: UserTrip.select(:trip_id).where(user_id:  params[:user_id],status: 'accepted')))
      else
        @trips = Trip.where(created_by: current_user.id).
            or(Trip.where(id: UserTrip.select(:trip_id).where(user_id:  current_user.id,status: 'accepted')))
      end
      if params[:show_image].to_i == 1
        @trips = @trips.joins(:attachments)
      end
      if params[:country]
        @trips = @trips.joins(',LATERAL jsonb_array_elements(trips.trip_schedule) as e(obj)')
      end
      condition = buid_condition(params)
      @trips = @trips.where(condition[0].join(" AND "),*condition[1]).
          group(Trip.column_names).order('start_date desc, trips.created_at  desc').
          page(page).per(per_page)

      result = @trips.map do|trip|
        trip.show_belong = true
        trip.trip_schedule = trip.trip_schedule.sort { |x,y| x['start_date'] <=> y['start_date'] }
        trip.show_last_image = params[:show_image].to_i == 1
        TripSerializer.new(trip,scope: {current_user: current_user})
      end
      respond_without_location({result: result,total_count: @trips.total_count, page: @trips.current_page, last_page: @trips.last_page?})
    rescue => e
      Rails.logger.info( e.backtrace.join("\n"))
      respond_error "Can't load trips"
    end

  end

  swagger_api :list_trip_of_friend do
    summary "List trip of friend"
    Api::ApiController.add_common_params(self)
    param :query, :page, :string, :optional, "Default 1 "
    param :query, :per_page, :string, :optional, "Default 20 "
    param :query, :show_image, :string, :optional, "1 if show image"
    param :query, :country, :string, :optional, "Search for country code"
    param :query, :friend_id, :string, :optional, "Search for friend"
    param :query, :user_id, :string, :optional, "Get trip by user"
  end
  def list_trip_of_friend
    begin
      page = params[:page] || 1
      per_page = params[:per_page] || 5
      @trips = Trip.all
      if params[:show_image].to_i == 1
        @trips = @trips.joins(:attachments)
      end
      if params[:country]
        @trips = @trips.joins(',LATERAL jsonb_array_elements(trips.trip_schedule) as e(obj)')
      end
      condition = buid_trip_of_friend_condition(params)
      @trips = @trips.where(condition[0].join(" AND "),*condition[1])
      if params[:user_id].present?
        @trips= @trips.where(created_by: params[:user_id])
      else
        @trips= @trips.where("trips.id IN (#{UserTrip.accepted.select(:trip_id).where(user_id: current_user.id).to_sql})")
      end
      @trips= @trips.group(Trip.column_names).
          order('start_date desc, trips.created_at  desc').
          page(page).per(per_page)
      result = @trips.map do|trip|
        trip.show_belong = true
        trip.trip_schedule = trip.trip_schedule.sort { |x,y| x['start_date'] <=> y['start_date'] }
        trip.show_last_image = params[:show_image].to_i == 1
        TripSerializer.new(trip,scope: {current_user: current_user, user_trip: User.find(params[:user_id])})
      end

      respond_without_location({result: result,total_count: @trips.total_count, page: @trips.current_page, last_page: @trips.last_page?})
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Can't load trips"
    end
  end

  swagger_api :get_friend_trip do
    summary "List trip of friend"
    Api::ApiController.add_common_params(self)
    param :query, :page, :string, :optional, "Default 1 "
    param :query, :per_page, :string, :optional, "Default 20 "
    param :query, :country, :string, :optional, "Search for country code"
    param :path, :id, :string, :optional, "Get trip by user"
  end
  def get_friend_trip
    begin
      page = params[:page] || 1
      per_page = params[:per_page] || 5
      @trips = Trip.all
      if params[:country]
        @trips = @trips.joins(',LATERAL jsonb_array_elements(trips.trip_schedule) as e(obj)')
      end
      condition = buid_trip_of_friend_condition(params)
      @trips = @trips.where(condition[0].join(" AND "),*condition[1])
      @trips= @trips.where(created_by: [params[:id],current_user.id]).
          where("trips.id IN (#{UserTrip.accepted.select(:trip_id).where(user_id: [params[:id],current_user.id]).to_sql})").
          order('start_date desc, trips.created_at  desc').
          page(page).per(per_page)

      result = @trips.map do|trip|
        trip.show_belong = true
        trip.trip_schedule = trip.trip_schedule.sort { |x,y| x['start_date'] <=> y['start_date'] }
        TripSerializer.new(trip,scope: {current_user: current_user, user_trip: User.find(params[:id])})
      end

      respond_without_location({result: result,total_count: @trips.total_count, page: @trips.current_page, last_page: @trips.last_page?})
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Can't load trips"
    end
  end

  swagger_api :list_detail_by_country do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "Trip ID "
    param :query, :country, :string, :require, "Country Code "
  end

  def list_detail_by_country
    begin
      city_serevice = CityServices.new({trip_id: params[:id], country: params[:country]}, current_user)

      respond_without_location(city_serevice.get_city_detail_by_country)
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Can't load cities"
    end

  end


  swagger_api :show do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "Trip ID "
  end
  def show
    begin
      @trip = Trip.find_by(id: params[:id])
      @trip.show_user_join_trip  = true
      @trip.trip_schedule = @trip.trip_schedule.sort { |x,y| x['start_date'] <=> y['start_date'] }

      respond_without_location(TripSerializer.new(@trip) )
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "trip not exist"
    end

  end


  swagger_api :create do
    summary "Create new trip"
    Api::ApiController.add_common_params(self)
    param :form, :name, :string, :require, 'email'
    # param :form, :description, :string, :require, "description"
    # param :form, :lat, :double, :optional, "lat"
    # param :form, :long, :double, :optional, "long"
    param :form, :start_date, :integer, :require, "Unit time"
    param :form, :end_date, :integer, :require, "Unit time"
    param :form, :cover_picture, :file, :require, "File"
    param :form, :trip_schedule, :string, :optional, 'List Country Code "VN,US"'
    param :form, :user_in_strip_ids, :string, :optional, "User ID list  1,3,4 "
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end

  def create
    begin
      trip_service = TripServices.new(current_user: current_user)
      @trip = trip_service.create_new_trip(params)
      respond_without_location  TripSerializer.new(@trip), :created
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Can't create trip"
    end
  end

  # PATCH/PUT /api/v1/trips/1
  swagger_api :update do
    summary "Create new trip"
    Api::ApiController.add_common_params(self)
    param :path, :id, :string, :require, 'Trip ID'
    param :form, :name, :string, :require, 'Name'
    param :form, :start_date, :integer, :require, "Unit time"
    param :form, :end_date, :integer, :require, "Unit time"
    param :form, :trip_schedule, :array, :optional, 'List Country Code is array [VN,US]'
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def update
   begin
     trip_service = TripServices.new(current_user: current_user)
     @trip = trip_service.update_new_trip(params)
     respond_without_location  TripSerializer.new(@trip)
   rescue => e
     Rails.logger.info(e.backtrace.join("\n"))
     Rails.logger.info(e.message)
     respond_error "Can't edit trip"
   end
  end

  swagger_api :destroy do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "Trip ID"
  end
  def destroy
    begin
      @trip = Trip.find_by(id: params[:id], created_by: current_user.id)
      @trip.destroy!
      respond_success "Trip destroy success"
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error "Can't destroy trip"
    end


  end

  swagger_api :list_image do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "Trip ID"
    param :query, :page, :string, :optional, "Default 1 "
    param :query, :per_page, :string, :optional, "Default 20 "
  end
  def list_image
    begin
      page = params[:page] || 1
      per_page = params[:per_page] || 5
      set_trip
      @images = @trip.attachments.with_type(:picture).order(uploaded_at: :desc,created_at: :desc).page(page).per(per_page)
      result = @images.map{|image| AttachmentSerializer.new(image,scope: current_user)}
      respond_without_location({result: result,total_count: @images.total_count, page: @images.current_page, last_page: @images.last_page?})
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error "Can't load trip image"
    end

  end

  def get_images_of_friend

  end

  swagger_api :get_trip_invited do
    summary "List invite trip"
    Api::ApiController.add_common_params(self)
  end
  def get_trip_invited
    begin
      user = User.find(current_user.id)
      trips =  user.trip_invited.order(created_at: :desc)

      respond_without_location(trips.map{|trip| TripSerializer.new(trip) })
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error e.message
    end
  end

  swagger_api :get_trip_accepted do
    summary "List accepted trip"
    Api::ApiController.add_common_params(self)
  end
  def get_trip_accepted
    begin
      user = User.find(current_user.id)
      trips =  user.trip_accepted.order(created_at: :desc)

      respond_without_location(trips.map{|trip| TripSerializer.new(trip) })
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Can't load trip"
    end
  end

  swagger_api :ignored_trip do
    summary "ignored trip"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "Trip ID"
    param :form, :notification_id, :integer, :require, "Notification ID"
  end
  def ignored_trip
    begin
      trip = Trip.find(params[:id])
      user = User.find(current_user.id)
      trip_user= user.user_trips.find_by(trip_id: params[:id])
      notification = current_user.notifications.find_by(id: params[:notification_id])
      Trip.transaction do
        trip_user.destroy!
        trip.user.notification_ignored_trip(trip,user)
        notification.reject_invite_trip!
      end

      respond_success("trip is ignored")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error 'This trip has been deleted'
    end
  end

  swagger_api :invite_trip do
    summary "ignored trip"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "Trip ID"
    param :form, :user_id, :integer, :require, "Notification ID"
  end
  def invite_trip
    begin
      user = User.find(params[:user_id])
      trip = Trip.find(params[:id])
      trip_user= UserTrip.find_by(trip_id: trip.id, user_id: user.id)
      if trip_user.present?
        if trip_user.status == "ignored"
          trip_user.status = "invited"
          trip_user.save!
          user.send_notification_invite_trip(trip, current_user)
          respond_success("trip was invited to #{user.name}")
        else
          respond_error "You have invited #{user.name} already "
        end
      else
        UserTrip.create(trip_id: trip.id, user_id: user.id,status: 'invited' )
        user.send_notification_invite_trip(trip, current_user)
        respond_success("trip was invited to #{user.name}")

      end
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "This trip has been deleted"
    end
  end


  swagger_api :accepted_trip do
    summary "accepted trip"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "Trip ID"
    param :form, :notification_id, :integer, :require, "Notification ID"
  end
  def accepted_trip
    begin
      user = User.find(current_user.id)
      trip_user= user.user_trips.find_by(trip_id: params[:id])
      trip = Trip.find(params[:id])
      notification = current_user.notifications.find_by(id: params[:notification_id])
      Trip.transaction do
        trip_user.accept_trip
        notification.accept_trip!
      end

      respond_success("trip is accepted")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error 'This trip has been deleted'
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params[:id])
      @trip.show_user_join_trip  = true
    end

    # Only allow a trusted parameter "white list" through.

end
