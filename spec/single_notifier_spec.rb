require 'spec_helper'

describe Notifiable::Mpns::Nverinaud::SingleNotifier do
  
  let(:m) { Notifiable::Mpns::Nverinaud::SingleNotifier.new }
  let(:d) { Notifiable::DeviceToken.create(:token => "http://db3.notify.live.net/throttledthirdparty/01.00/123456789123456798", :provider => :mpns) }
  let(:u) { User.new(d) }
  
  it "sends a notification with a title" do
    n = Notifiable::Notification.create(title: "A title")   

    stub_request(:post, d.token)
         
    m.send_notification(n, d)
    m.close
    
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 200
    
    a_request(:post, d.token)
      .with(:body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><wp:Notification xmlns:wp=\"WPNotification\"><wp:Toast><wp:Text1>A title</wp:Text1><wp:Text2></wp:Text2><wp:Param></wp:Param></wp:Toast></wp:Notification>")
      .should have_been_made.once
  end
  
  it "sends a single mpns notification with content" do
    n = Notifiable::Notification.create(message: "A message")   
    stub_request(:post, d.token)
         
    m.send_notification(n, d)
    m.close
    
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 200
    
    a_request(:post, d.token)
      .with(:body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><wp:Notification xmlns:wp=\"WPNotification\"><wp:Toast><wp:Text1></wp:Text1><wp:Text2>A message</wp:Text2><wp:Param></wp:Param></wp:Toast></wp:Notification>")
      .should have_been_made.once
  end
  
  it "sends custom attributes" do 
    n = Notifiable::Notification.create(:params => {:an_object_id => 123456})    
    
    stub_request(:post, d.token) 
         
    m.send_notification(n, d)
    m.close
    
    Notifiable::NotificationStatus.count.should == 1
    a_request(:post, d.token)
      .with(:body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><wp:Notification xmlns:wp=\"WPNotification\"><wp:Toast><wp:Text1></wp:Text1><wp:Text2></wp:Text2><wp:Param>?an_object_id=123456</wp:Param></wp:Toast></wp:Notification>")
      .should have_been_made.once
  end
  
  it "de-registers a device on receiving a 404 status from MPNS" do
    n = Notifiable::Notification.create(:message => "A message")   
        
    stub_request(:post, d.token).to_return(:status => 404)
         
    m.send_notification(n, d)
    m.close
    
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 404
    Notifiable::DeviceToken.first.is_valid.should == false
  end
  
end