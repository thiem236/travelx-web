class Api::V1::InvitesController < Api::ApiController

  swagger_controller :invites, "Invites controller"

  swagger_api :index do
    summary "Get user invite"
    Api::ApiController.add_common_params(self)
  end
  def index
    invites = Invite.where(sent_by: current_user.id).pluck(:contact)
    respond_without_location(invites)
  end
  swagger_api :create do
    summary "Sent invite"
    Api::ApiController.add_common_params(self)
    param :form, :contact, :string, :require
    param :form, :country, :string, :require
    param :form, :dynamic_link, :string, :require
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def create
    begin
      user = User.get_user_by_contact(params[:contact])
      if user.present?
        if current_user.auto_add_friend(user)
          respond_success("you and #{user.name} is a friend")
        else
          respond_error("#{user.name} was blocked you ")
        end
      else
        invite  = Invite.new(invite_params.merge(sent_by: current_user.id))
        invite.save!
        respond_success("send invite is success")
      end
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error 'Operation could not be completed.'
    end
  end

  swagger_api :invite_all do
    summary "Sent invite"
    Api::ApiController.add_common_params(self)
    param :form, :contacts, :array, :require
    response :unauthorized
    response :not_acceptable
    response :unprocessable_entity
  end
  def invite_all
    begin
      invites = []
      params[:contacts].each do |phone|
        Invite.delay.create contact: phone, sent_by: current_user.id
      end
      respond_success("send invite is success")
    rescue => e
      Rails.logger.info(hash_exception(e))
      respond_error 'Operation could not be completed.'
    end

  end

  private
  def invite_params
    params.permit(:contact, :country,:dynamic_link)
  end
end
