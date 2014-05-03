require 'notifiable'
require 'ruby-mpns'

module Notifiable
  module Mpns
    module Nverinaud
  		class SingleNotifier < Notifiable::NotifierBase
        
        protected 
    			def enqueue(device_token)
                        
            data = {title: notification.title, content: notification.message, params: notification.send_params}    
            
            response = MicrosoftPushNotificationService.send_notification(device_token.token, :toast, data)
            response_code = response.code.to_i
            
            status_code = 0
            case response_code
            when 200
            when 404
              Rails.logger.info "De-registering device token: #{device_token.id}"
              device_token.update_attribute('is_valid', false)
              status_code = 1
            else
              Rails.logger.error "Error sending notification: #{response.code}"  
              status_code = 2            
            end
            
            processed(device_token, status_code)
      		end
  		end
    end
	end
end