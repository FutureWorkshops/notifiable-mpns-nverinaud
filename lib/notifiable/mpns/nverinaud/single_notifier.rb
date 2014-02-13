require 'notifiable'
require 'ruby-mpns'

module Notifiable
  module Mpns
    module Nverinaud
  		class SingleNotifier < Notifiable::NotifierBase
        
        protected 
    			def enqueue(n, device_token)
                        
            data = {title: n.title, content: n.message, params: n.params}    
            
            response = MicrosoftPushNotificationService.send_notification device_token.token, :toast, data
            response_code = response.code.to_i
            
            case response_code
            when 200
            when 404
              Rails.logger.info "De-registering device token: #{device_token.id}"
              device_token.update_attribute('is_valid', false)
            else
              Rails.logger.error "Error sending notification: #{response.code}"              
            end
            
            processed(n, device_token, response_code)
            
      		end
  		end
    end
	end
end