# Monkey path gem https://github.com/visualitypl/textris
module Textris
  module Delivery
    class Twilio < Textris::Delivery::Base
      def deliver(to)
         client.messages.create(
          :from => phone_with_plus(message.from_phone),
          :to   => phone_with_plus(to),
          :messaging_service_sid => ENV["TWILIO_MESSAGING_SERVICE_SID"],
          :body => message.content)
      end
    end
  end
end
