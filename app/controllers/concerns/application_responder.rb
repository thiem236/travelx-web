require 'active_support/concern'
module ApplicationResponder
  def respond_without_location(resource, status = 200)
    render json: {data: resource, success: true}, status: status, root: false
  end

  def respond_without_hash(resource, status = 200)
    render json: {data: resource.as_json, success: true}, status: status, root: false
  end

  def respond_error(errors, status= :bad_request)
    res = {
        success: false,
        errors: errors
    }
    # respond_with res, status: status, location: nil
    render json: res.as_json, status: status, location: nil
    return
  end

  def respond_success(message = '', status = 200)
    res = {
        success: true,
        message: message
    }
    # respond_with res, status: status, location: nil
    render json: res, status: status, location: nil
  end

  def hash_exception(e)
    {
        exception_detail: e.backtrace,
        full_messages: [
            e.message
        ]
    }
  end

  def custom_header

    response.set_header 'Token-Type' , response.headers.delete('token-type') if response.headers['token-type'].present?
    response.set_header 'Access-Token' , response.headers.delete('access-token') if response.headers['access-token'].present?
    response.set_header 'Client' , response.headers.delete('client') if response.headers['client'].present?
    response.set_header 'Uid' , response.headers.delete('uid') if response.headers['uid'].present?
    response.set_header 'Expiry' , response.headers.delete('expiry') if response.headers['expiry'].present?
    byebug
  end
end
