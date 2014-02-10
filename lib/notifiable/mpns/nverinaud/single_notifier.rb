require 'notifiable'
require 'ruby-mpns'

module Notifiable
  module Mpns
    module Nverinaud
  		class SingleNotifier < Notifiable::NotifierBase
        
        protected 
    			def enqueue(notification, device_token)
                        
            data = {}
            
            # title
            title = notification.provider_value(device_token.provider, :title)
            data[:title] = title if title   
                        
            # content
            content = notification.provider_value(device_token.provider, :message)
            data[:content] = content if content    
            
            # custom attributes
            custom_attributes = notification.provider_value(device_token.provider, :params)
            data.merge!({:params => custom_attributes}) if custom_attributes    
            
            response = MicrosoftPushNotificationService.send_notification device_token.token, :toast, data
            
            case response.code.to_i
            when 200              
              processed(notification, device_token)
            when 404
              Rails.logger.info "De-registering device token: #{device_token.id}"
              device_token.update_attribute('is_valid', false)
            else
              Rails.logger.error "Error sending notification: #{response.code}"              
            end
      		end
  		end
    end
	end
end