class Api::V1::StampsController < Api::ApiController
  swagger_controller :stamps, "Trip image controller"
  # swagger_api :public_stamps do
  #   summary "Upload image"
  #   Api::ApiController.add_common_params(self)
  #   param :query, :country, :string, :optional, 'Country code '
  #   param :query, :page, :string, :optional, "Default 1 "
  #   param :query, :per_page, :string, :optional, "Default 5 "
  #   response :unauthorized
  #   response :not_acceptable
  #   response :unprocessable_entity
  # end
  def public_stamps
    begin
      page = params[:page] || 1
      per_page = params[:per_page] || 5
      stamps = PublicStamp.all
      if params[:country].present?
        stamps = stamps.where(country: params[:country])
      end
      stamps = stamps.page(page).per(per_page)
      respond_without_location({result: stamps.map{|stamp| StampSerializer.new(stamp,scope: current_user)},
                                total_count: stamps.total_count,
                                page: stamps.current_page,
                                last_page: stamps.last_page?})
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error 'Operation could not be completed.'
    end

  end

  swagger_api :index do
    summary "Get stamp by current user"
    Api::ApiController.add_common_params(self)
    param :query, :country, :string, :optional, 'Country code '
    param :query, :user_id, :string, :optional, 'User'
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def index
    begin

      if params[:user_id].present?
        stamps = PrivateStamp.where(user_id:  params[:user_id])
      else
        stamps = current_user.private_stamps
      end
      if params[:country].present?
        stamps = stamps.where(country: params[:country])
      end
      stamps = stamps.order(created_at: :desc)
      respond_without_location stamps.map {|stamp| StampSerializer.new(stamp)}
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error 'Operation could not be completed.'
    end

  end

  swagger_api :create do
    summary "Update image"
    Api::ApiController.add_common_params(self)
    # param :form, :image, :file, :require, 'image '
    param :form, :country, :string, :require, 'country '
    param :form, :uploaded_at, :integer, :require, 'time create'
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def create
    begin
      params[:uploaded_at] ||= Time.zone.now.to_i
      stamp = PrivateStamp.new(stamp_params.merge(user_id: current_user.id))
      stamp.save!
      respond_without_location  StampSerializer.new(stamp,scope: current_user), 201
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error 'Operation could not be completed.'
    end
  end

  # swagger_api :create_public_stamp do
  #   summary "Update image"
  #   Api::ApiController.add_common_params(self)
  #   param :form, :country, :string, :require, 'City '
  #   param :form, :image, :file, :require, 'City '
  #   response :unauthorized
  #   response :not_acceptable
  #   response :unprocessable_entity
  # end
  def create_public_stamp
    begin
      stamp = PublicStamp.new(public_stamp_params)
      stamp.save!
      respond_without_location  StampSerializer.new(stamp,scope: current_user), 200
    rescue => e
      Rails.logger.info(e.backtrace.join("\n"))
      Rails.logger.info(e.message)
      respond_error 'Operation could not be completed.'
    end
  end

  private

  def stamp_params
    params.permit( :image,:country,:uploaded_at)
  end
end
