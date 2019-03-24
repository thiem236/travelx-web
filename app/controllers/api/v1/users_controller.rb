class Api::V1::UsersController < Api::ApiController
  skip_before_action :authenticate_user!, only: [:verify_register]
  swagger_controller :UsersController, "UsersController"

  def index
    if params[:q]
      @users = User.search(params[:q],where: {id: {not: current_user.id}}, misspellings: {edit_distance: 5})
    else
      @users = User.where.not(id: current_user.id)
    end
    @users = @users.length > 0 ? @users : {users: []}
    render json: @users, user_id: current_user.id
  end

  swagger_api :update_profile do |api|
    summary 'Create a new User item'
    # param :body, :sign_up, :sign_up, :require, 'User object'
    Api::ApiController.add_common_params(self)
    param :form, 'name', :string, :require, 'First Name'
    param :form, 'profile_picture', :file, :optional, 'File'
    param :form, 'cover_picture', :file, :optional, 'File'
    param :form, 'email', :string, :require, 'contact(email)'
    param :form, 'contact', :string, :require, 'contact(phone)'
    param :form, 'country', :string, :require, 'country'
    param :form, 'fb_id', :string, :optional, 'Facebook id, if user connect fb'
    param :form, 'password', :string, :optional, 'password'
    param :form, 'password_confirmation', :string, :optional, 'password'
    param :form, 'allow_notification', :boolean, :optional, 'allow_notification'
    param :form, 'allow_tag_me', :boolean, :optional, 'allow_tag_me'
    param :form, 'receive_message', :boolean, :require, 'recive_message'
    param :form, 'city', :string, :optional, 'city'
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end

  def update_profile
    begin
      user = User.find(current_user.id)
      if user.update_attributes(user_params)
        render json: user
      else
        respond_error user.errors.messages.values.join(", "), :not_acceptable
      end

    rescue => e
      Rails.logger.info( e.backtrace.join("\n"))
      Rails.logger.info( e.message)
      respond_error "Can't update profile", :not_acceptable
    end
  end

  swagger_api :show do
    summary "Verified code"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :required, "id"
  end
  def show
    begin
      user = User.find(params[:id])
      total_image = Attachment.joins(:trip).where('trips.created_by = ?',user.id).count
      total_trip = Trip.where(created_by: user.id).count
      total_temp = user.private_stamps.count
      respond_without_location user: UserSerializer.new(user),total_image: total_image, total_trip: total_trip, total_temp: total_temp
    rescue => e
      Rails.logger.info( e.backtrace.join("\n"))
      Rails.logger.info( e.message)
      respond_error "Can't load user infor", :not_acceptable
    end
  end

  swagger_api :verify_register do
    summary "Verified code"
    Api::ApiController.add_common_params(self)
    param :path, :id, :integer, :required, "id"
    param :form, 'verification_code', :string, :required, "verification_code"
  end
  def verify_register
    begin
      user = User.find_by(email: request.headers["uid"])
      user.verify!(params['verification_code'])
      respond_success("ok")
    rescue SecurityError =>e
      respond_error e.message
    rescue =>e
      respond_error e.message
    end
  end

  swagger_api :resend_verification_code do
    summary "Returns users"
    param :form, 'email', :string, :required, 'auth token'
    param :path, :id, :integer, :required, "id"
  end
  def resend_verification_code
    current_user.generate_verification_code_and_send
    render json: @user, user_id: current_user.id, status: :ok
  end

  swagger_api :accept_trip do
    summary "Accept trip"
    Api::ApiController.add_common_params(self)
    param :form, 'trip_id', :integer, :required, 'User ID'
  end
  def accept_trip
    current_user.accept_trip(params[:trip_id])
    respond_success("ok")
  end

  swagger_api :ignore_friend do
    summary "Accept trip"
    Api::ApiController.add_common_params(self)
    param :form, 'user_id', :integer, :required, 'User ID'
  end
  def ignore_friend
    @friend = User.find_by(id: params[:user_id])
    current_user.decline_request(@friend)
    # noti = NotificationServices.new(@friend,current_user,nil)
    # noti.send_noti_add_friend('accepted_friend')
    respond_success("ok")
  end


  def trip_list
    @user = current_user.friends
    respond_with @user
  end

  swagger_api :friend_list do
    summary "Returns friend list"
    Api::ApiController.add_common_params(self)
    # param :form, 'trip_id', :integer, :required, 'User ID list'
  end
  def friend_list
    users = current_user.friends
    respond_without_location(users.map{|u| UserSerializer.new(u, user_id: current_user.id)})
  end

  swagger_api :get_user_by_contact do
    summary "Sync user "
    Api::ApiController.add_common_params(self)
    param :form, 'contacts', :array, :required, 'Contact list'
  end
  def get_user_by_contact
    begin
      user_service = UserServices.new(user_params: params, current_user: current_user)
      users = user_service.sync_friend
      respond_without_location(users.map{|u| UserSerializer.new(u)})
    rescue => e
      Rails.logger.info( e.backtrace.join("\n"))
      respond_error "Cannot Not sync contact"
    end

  end

  swagger_api :get_user_by_fb do
    summary "Sync user "
    Api::ApiController.add_common_params(self)
    param :form, 'fb_ids', :array, :required, 'Contact list'
  end
  def get_user_by_fb
    begin
      user_service = UserServices.new(user_params: params, current_user: current_user)
      users = user_service.sync_friend_from_fb
      respond_without_location(users.map{|u| UserSerializer.new(u)})
    rescue => e
      Rails.logger.info( e.backtrace.join("\n"))
      Rails.logger.info( e.message)
      respond_error "Cannot Not sync contact"
    end

  end

  def add_friend
    user = User.find_by_id(params[:user_id])
    if current_user.friend_request(user)
      respond_success("Request sent success")
    else
      respond_error("Cannot Not add friend")
    end
  end

  swagger_api :update_device_token do
    summary "Update user token "
    Api::ApiController.add_common_params(self)
    param :form, :platform, :string, :require, "ios/android"
    param :form, :device_token, :string, :require, "Device toke"
  end
  def update_device_token
    begin
      if current_user.device_tokens.is_a?Array
        if current_user.device_tokens.select{|d| d['device_token'] == params[:device_token]}
          current_user.device_tokens = [{device_token: params[:device_token], device_name: params[:platform] }] + current_user.device_tokens
          current_user.device_tokens.pop if current_user.device_tokens.length >= 10
        end

      else
        current_user.device_tokens = [{device_token: params[:device_token], device_name: params[:platform]}]
      end
      current_user.save!
      respond_success("update token success")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Cannot Not sync contact"
    end

  end

  swagger_api :delete_friend do
    summary "Update user token "
    Api::ApiController.add_common_params(self)
    param :form, :friend_id, :integer, :require, "friend id"
  end
  def delete_friend
    begin
      user = User.find(params[:friend_id])

      if current_user.friends_with?(user)
        current_user.remove_friend(user)
      end

      respond_success("remove friend success")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error "Cannot Not remove friend"
    end
  end

  swagger_api :update_badge do
    summary "Update user badge "
    Api::ApiController.add_common_params(self)
  end
  def update_badge
    begin
      current_user.reset_badge!
      respond_success("update bage success")
    rescue
      Rails.logger.info(hash_exception(e))
      respond_error "Cannot Not sync contact"
    end

  end

  swagger_api :friends_request do
    summary "Returns users who send request you add to friend list"
    Api::ApiController.add_common_params(self)
    # param :form, 'trip_id', :integer, :required, 'User ID list'
  end
  def friends_request
    @users = current_user.requested_friends
    respond_without_location @users
  end

  swagger_api :accept_friend do
    summary "Accept friend "
    Api::ApiController.add_common_params(self)
    param :form, 'user_id', :integer, :required, 'User ID '
  end
  def accept_friend
    @friend = User.find_by(id: params[:user_id])
    current_user.accept_request(@friend)
    noti = NotificationServices.new(@friend,current_user,nil)
    noti.send_noti_add_friend('accepted_friend')
    respond_success("ok")
  end


  private
  def user_params
    params.permit(:name,
                  :profile_picture,
                  :cover_picture,
                  :password,
                  :password_confirmation,
                  :contact,
                  :email,
                  :country,
                  :allow_notification,
                  :allow_tag_me,
                  :receive_message,
                  :fb_id,
                  :city)
  end
end
