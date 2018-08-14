class Api::V1::TripImagesController < Api::ApiController
  swagger_controller :trip_images, "Trip image controller"

  swagger_api :index do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "Trip ID"
    param :query, :page, :string, :optional, "Default 1 "
    param :query, :per_page, :string, :optional, "Default 20 "
    param :query, :user_id, :string, :optional, "User id"
    param :query, :trip_id, :string, :optional, "trip id"
  end
  def index
    begin
      page = params[:page] || 1
      per_page = params[:per_page] || 5
      if params[:user_id].present?
        @images = Attachment.joins(:trip).where('trips.created_by = ?',params[:user_id])
      else
        @images = Attachment.joins(:trip).where('trips.created_by = ?',current_user.id)
      end
      @images = @images.with_type(:picture).order(uploaded_at: :desc,created_at: :desc).page(page).per(per_page)
      result = @images.map{|image| AttachmentSerializer.new(image,scope: current_user)}
      respond_without_location({result: result,total_count: @images.total_count, page: @images.current_page, last_page: @images.last_page?})
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error "Can't not load images "
    end

  end
  swagger_api :create do
    summary "Upload image"
    Api::ApiController.add_common_params(self)
    param :path, :trip_id, :integer, :require, 'Trip ID '
    param :form, :country, :string, :require, 'Country code '
    param :form, :country_name, :string, :optional, 'Country name '
    param :form, :city, :string, :require, 'City '
    param :form, :lat, :decimal, :optional, 'Lat '
    param :form, :long, :decimal, :optional, 'Long '
    param :form, :uploaded_at, :integer, :require, 'date take photo (Unit time)'
    param :form, :caption, :string, :optional, 'Caption of photo'
    param :form, :file, :file, :require, 'File'
    param :form, :item_type, :string, :require, 'Item Type IN [hotel,restaurant,museum, bar], example: hotel'
    param :form, :item_name, :string, :require
    param :form, :item_id, :string, :require
    param :form, :user_id, :integer, :optional
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def create
    begin
      trip_image_service = TripImageServices.new(current_user: current_user, trip_params: params,trip: Trip.find(params[:trip_id]))
      @attachemnt =trip_image_service.upload_image
      respond_without_location  AttachmentSerializer.new(@attachemnt,scope: current_user), :created
    rescue => e
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      respond_error "Can't upload image"
    end

  end

  def get_last_image_in_trip

  end

  swagger_api :show do
    summary "Delete image"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, 'Image ID '
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def show
    begin
      @image = Attachment.find(params[:id])
      @image.show_has_many = true
      respond_without_location  AttachmentSerializer.new(@image,scope: current_user)
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      respond_error "Can't find image"
    end

  end

  swagger_api :update do
    summary "Update image"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, 'Image ID '
    param :form, :trip_id, :integer, :optional, 'Trip ID '
    param :form, :country, :string, :require, 'Country code '
    param :form, :country_name, :string, :optional, 'Country name '
    param :form, :city, :string, :require, 'City '
    param :form, :lat, :decimal, :optional, 'Lat '
    param :form, :long, :decimal, :optional, 'Long '
    param :form, :uploaded_at, :integer, :require, 'date take photo (Unit time)'
    param :form, :caption, :string, :optional, 'Caption of photo'
    param :form, :item_type, :string, :require, 'Item Type IN [hotel,restaurant,museum, bar, unknown], example: hotel'
    param :form, :item_name, :string, :require
    param :form, :item_id, :string, :require
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def update
    begin
      trip_image_service = TripImageServices.new(current_user: current_user, trip_params: params, trip: Trip.find(params[:trip_id]))
      @attachemnt =trip_image_service.edit_image
      respond_without_location  AttachmentSerializer.new(@attachemnt,scope: current_user), 200
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Can't edit image"
    end
  end

  swagger_api :destroy do
    summary "Delete image"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, 'Image ID '
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def destroy
    begin

      @image = Attachment.find(params[:id])
      @trip = @image.trip
      @image.destroy
      @trip.update_trip_schedule
      respond_success("success")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Can't delete image"
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
      @attachemnt = Attachment.find(params[:id])
      if params[:behavior].strip == 'like'
        unless @attachemnt.likes.include?(current_user.id)
          @attachemnt.likes << current_user.id
          @attachemnt.likes = @attachemnt.likes.uniq
          @attachemnt.save
          trip = @attachemnt.trip
          trip.update(total_like:(trip.total_like.to_i + 1))
          noti = NotificationServices.new(trip.user,current_user,@attachemnt)
          noti.send_noti_action('liked')
        end
      else
        if @attachemnt.likes.include?(current_user.id)
          @attachemnt.likes  = @attachemnt.likes.delete_if{|i|i.to_i == current_user.id }
          @attachemnt.save
          trip = @attachemnt.trip
          trip.update(total_like:(trip.total_like.to_i - 1))
        end
      end
      respond_without_location(AttachmentSerializer.new(@attachemnt,scope: current_user))
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Sorry, Please try later"
    end

  end

  swagger_api :add_comment do
    summary "Login use"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :require, "City ID id"
    param :form, :content, :string, :require, "Content"
  end
  def add_comment
    begin
      @attachemnt = Attachment.find(params[:id])
      trip = @attachemnt.trip
      trip.update_attribute(:total_comment,(trip.total_comment.to_i + 1))
      @comment = @attachemnt.comments.new(comment_params.merge(user_id: current_user.id))
      @comment.save
      @attachemnt.update_post(current_user)
      noti = NotificationServices.new(trip.user,current_user,@attachemnt)
      noti.send_noti_action('commented')
      respond_without_location(CommentSerializer.new(@comment), 201)
    rescue => e
      raise e
      respond_error "Sorry, Please try later"
    end
  end

  def comments

  end

  private

  def comment_params
    params.permit( :content)
  end
end
