class Api::V1::CitiesController < Api::ApiController
  swagger_controller :cities, "Cities controller"
  # GET /api/v1/trips
  swagger_api :index do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :trip_id, :integer, :require, "Trip id"
  end

  def index
    begin
      city_serevice = CityServices.new({trip_id: params[:trip_id]}, current_user)
      result = city_serevice.get_country_detail_by_trip
      respond_without_location(result)
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error e.message
    end

  end
  swagger_api :show do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "City Id"
  end
  def show
    begin
      @city = City.find(params[:id])
      @city.show_all
      respond_without_location(CitySerializer.new(@city,scope: current_user))
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error e.message
    end
  end

  swagger_api :user_like do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "City ID id"
    param :query, :behavior, :string, :require, "like or unlike"
  end
  def user_like
    begin
      @city = City.find(params[:id])
      if params[:behavior].strip =='like'
        unless @city.like.include?(current_user.id)
          @city.like << current_user.id
          @city.like.uniq!
          @city.save
          trip = @city.trip
          trip.update(total_like: (trip.total_like.to_i + 1))
          noti = NotificationServices.new(@city.user,current_user,@city)
          noti.send_noti_action('liked')
        end
      else
        if @city.like.include?(current_user.id)
          @city.like = @city.like.delete_if{|i|i.to_i ==current_user.id }
          @city.save
          trip = @city.trip
          trip.update(total_like: trip.total_like.to_i - 1)
        end
      end
      respond_without_location(CitySerializer.new(@city,scope: current_user))
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error e.message
    end

  end

  swagger_api :add_comment do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "City ID id"
    param :form, :content, :tring, :require, "Content"
  end
  def add_comment
    begin
      @city = City.find(params[:id])
      trip = @city.trip
      @comment = @city.comments.new(comment_params.merge(user_id: current_user.id))
      @comment.save
      trip.update_attribute(:total_comment,(trip.total_comment.to_i + 1))
      @city.update_post(current_user)
      noti = NotificationServices.new(@city.user,current_user,@city)
      noti.send_noti_action('commented')
      respond_without_location(@comment, 201)
    rescue => e
      raise e
      respond_error e.message
    end
  end

  swagger_api :destroy do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "City ID id"
  end
  def destroy
    begin
      @city = City.find(params[:id])
      trip = @city.trip
      @city.destroy!
      trip.update_trip_schedule
      respond_success("city was destroyed")
    rescue => e
      raise e
      respond_error e.message
    end

  end
  private

  def comment_params
    params.permit( :content)
  end

    # Only allow a trusted parameter "white list" through.

end
