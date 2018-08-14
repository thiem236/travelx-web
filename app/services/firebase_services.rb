class FirebaseServices
  attr_accessor :device_ids, :payload, :headers,:uri

  def initialize(params)
    @device_ids = params[:device_ids]
    @payload = params[:payload]
    @headers = {'Authorization' => 'key=' + ENV['SERVER_KEY'],
                'Content-Type' => 'application/json; UTF-8'}
    @uri = 'https://fcm.googleapis.com/fcm/send'

  end

  def send_single_devise
    HTTParty.post(@uri,headers: @headers,body: @payload)
  end

  def send_multy_device
    payload = {
        to: @device_ids.first,
        "content_available": true,
        "mutable_content": true,
        badge: 1,
        "notification":
            {
                "body": "Enter your message",
                "sound": "default",
                message: "hello"
            },
    }
    server_key = ENV['SERVER_KEY']
    body = {
        data: @payload,
        to: @device_ids.first
    }
    headers =  {'Authorization' => 'key=' +  ENV['SERVER_KEY'],
                'Content-Type' => 'application/json; UTF-8'}
    puts headers
    uri = 'https://fcm.googleapis.com/fcm/send'
    response = HTTParty.post(uri,headers: @headers,body: payload.to_json)
    response

  end
end