class Api::V1::ContactsController < Api::ApiController
  swagger_controller :ContactsController, "ContactsController"

  swagger_api :syn_user_by_contact do
    summary "Sync user "
    Api::ApiController.add_common_params(self)
    param :form, 'contacts', :array, :required, 'Contact list'
    param :form, 'emails', :array, :required, 'Email list'
  end
  def syn_user_by_contact
    begin
      user_service = UserServices.new(user_params: params, current_user: current_user)
      data = user_service.sync_email_or_contact
      respond_without_location(data)
    rescue => e
      Rails.logger.info( e.backtrace.join("\n"))
      Rails.logger.info( e.message)
      respond_error "Cannot Not sync contact"
    end

  end
end