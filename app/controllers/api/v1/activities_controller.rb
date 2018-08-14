class Api::V1::ActivitiesController < Api::ApiController
  swagger_controller :activities, "Activites controller"
  # GET /api/v1/trips
  swagger_api :index do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :query, :page, :string, :optional, "Default 1 "
    param :query, :per_page, :string, :optional, "Default 20 "
  end

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 5
    begin
      @posts = Post.where("user_may_see @> ARRAY[?] or created_by = ?",[current_user.id],current_user.id).
          order(created_at: :desc).
          page(page).per(per_page)
      result = @posts.map{|p| PostSerializer.new(p)}
      respond_without_location({result: result,total_count: @posts.total_count, page: @posts.current_page, last_page: @posts.last_page?})

    rescue => e
      raise e
      respond_error e.message
    end

  end

  # GET /api/v1/trips/1
  def show
  end

  swagger_api :create do
    summary "Create new trip"
    Api::ApiController.add_common_params(self)
    param :form, :activity_id, :integer, :require, 'Content '
    param :form, :activity_type, :string, :require, 'Country, Album, Image, City, Stamp'
    param :form, :stamp_ids, :string, :array, 'List ID'
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def create
    begin
      ativity_service = ActivityServices.new(params,current_user)
      if params[:activity_type] == 'Stamp'
        message = ativity_service.create_stamps
      else
        message = ativity_service.create_activity
      end

      respond_success message
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error "Can't find #{params[:activity_type]} with id #{params[:activity_id]}"
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error "Share was error"
    end
  end

  # PATCH/PUT /api/v1/trips/1
  swagger_api :show do
    summary "Create new trip"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, 'Activity id '
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def show
    begin
      post = Post.find_by(id: params[:id])
      respond_without_location(PostSerializer.new(post) )
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      respond_error "Activity not exist"
    end
  end

  # DELETE /api/v1/trips/1
  def destroy
    set_trip
    @trip.destroy

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def trip_params
      params.permit(:trip_id, :post_type, :content, :name, :lat, :long)
    end
end
