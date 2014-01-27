require 'notifiable'
require 'ruby-mpns'

module Notifiable
  module Mpns
    module Nverinaud
  		class SingleNotifier < Notifiable::NotifierBase
        
        protected 
    			def enqueue(notification, device_token)
            
            options = {content: notification.message}
            response = MicrosoftPushNotificationService.send_notification device_token.token, :toast, options
            
            if response.code.eql? "200"
              processed(notification, device_token) 
            else
              Rails.logger.error "Error sending notification: #{response.code}"
            end
      		end
  		end
    end
	end
end