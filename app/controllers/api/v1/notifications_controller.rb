class Api::V1::NotificationsController < Api::ApiController

  swagger_controller :notifications, 'Notifications'

  swagger_api :index do
    summary "Returns all notification"
    Api::ApiController.add_common_params(self)
  end
  def index
    begin
      notifications = current_user.notifications.avaiable.where.not(noti_type: ['invited_friend','accepted_friend']).order(created_at: :desc)
      respond_without_location(notifications.map{|n| NotificationSerializer.new(n, scope: current_user)})
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error(e.message)
    end
  end

  swagger_api :count_notification do
    summary "Count notificaion"
    Api::ApiController.add_common_params(self)
  end
  def count_notification
    count =  current_user.notifications.unread.where.not(noti_type: ['invited_friend','accepted_friend']).count
    render json: {success: true, data: {total: count}}
  end

  swagger_api :update_read_all do
    summary "Update read all"
    Api::ApiController.add_common_params(self)
  end
  def update_read_all
    begin
      Notification.read_all!(current_user.id)
      respond_success("ok")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error(e.message)
    end
  end

  swagger_api :count_friend_noti do
    summary "Count notificaion"
    Api::ApiController.add_common_params(self)
  end
  def count_friend_noti
    count =  current_user.notifications.unread.where(noti_type: ['invited_friend','accepted_friend']).count
    render json: {success: true, data: {total: count}}
  end

  swagger_api :update_read_all_friend_noti do
    summary "Update read all"
    Api::ApiController.add_common_params(self)
  end
  def update_read_all_friend_noti
    begin
      Notification.read_all_friend_noti!(current_user.id)
      respond_success("ok")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error(e.message)
    end
  end

  swagger_api :destroy do
    summary "Update read all"
    Api::ApiController.add_common_params(self)
    param :path, :id, :string, :require, "notification ID"
  end
  def destroy
    begin
      Notification.find(params[:id]).destroy!
      respond_success("ok")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error(e.message)
    end
  end

  swagger_api :clear_notification do
    summary "clear all"
    Api::ApiController.add_common_params(self)
  end
  def clear_notification
    begin
      Notification.clear_all!(current_user.id)
      respond_success("ok")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error(e.message)
    end
  end
end
