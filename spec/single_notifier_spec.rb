require 'spec_helper'

describe Notifiable::Mpns::Nverinaud::SingleNotifier do
  
  let(:m) { Notifiable::Mpns::Nverinaud::SingleNotifier.new }
  let(:n) { Notifiable::Notification.create(:message => "Test message") }
  let(:d) { Notifiable::DeviceToken.create(:token => "http://db3.notify.live.net/throttledthirdparty/01.00/123456789123456798", :provider => :mpns) }
  let(:u) { User.new(d) }
  
  it "sends a single mpns notification" do    
    stub_request(:post, d.token)
         
    m.send_notification(n, d)
    m.close
    
    Notifiable::NotificationDeviceToken.count.should == 1
  end
  
  it "de-registers a device on receiving a 404 status from MPNS" do    
    stub_request(:post, d.token).to_return(:status => 404)
         
    m.send_notification(n, d)
    m.close
    
    Notifiable::NotificationDeviceToken.count.should == 0
    Notifiable::DeviceToken.first.is_valid.should == false
  end
  
end