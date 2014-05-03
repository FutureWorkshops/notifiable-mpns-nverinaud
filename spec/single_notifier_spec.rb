require 'spec_helper'

describe Notifiable::Mpns::Nverinaud::SingleNotifier do
  
  let(:a) { Notifiable::App.create }  
  let(:n1) { Notifiable::Notification.create(:title => "Test title", :app => a) }
  let(:n1_with_message) { Notifiable::Notification.create(:message => "Test message", :app => a) }
  let(:n1_with_params) { Notifiable::Notification.create(:message => "Test message", :app => a, :params => {:flag => true}) }
  let(:d) { Notifiable::DeviceToken.create(:token => "http://db3.notify.live.net/throttledthirdparty/01.00/123456789123456798", :provider => :mpns, :app => a) }
  
  it "sends a notification with a title" do
    stub_request(:post, d.token)
         
    n1.batch do |n|
      n.add_device_token(d)
    end
    
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 0
    
    a_request(:post, d.token)
      .with(:body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><wp:Notification xmlns:wp=\"WPNotification\"><wp:Toast><wp:Text1>Test title</wp:Text1><wp:Text2></wp:Text2><wp:Param>?notification_id=#{n1.id}</wp:Param></wp:Toast></wp:Notification>")
      .should have_been_made.once
  end
  
  it "sends a single mpns notification with a message" do
    stub_request(:post, d.token)
         
    n1_with_message.batch do |n|
      n.add_device_token(d)
    end
    
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 0
    
    a_request(:post, d.token)
      .with(:body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><wp:Notification xmlns:wp=\"WPNotification\"><wp:Toast><wp:Text1></wp:Text1><wp:Text2>Test message</wp:Text2><wp:Param>?notification_id=#{n1_with_message.id}</wp:Param></wp:Toast></wp:Notification>")
      .should have_been_made.once
  end
  
  it "sends custom attributes" do     
    stub_request(:post, d.token) 
         
    n1_with_params.batch do |n|
      n.add_device_token(d)
    end
    
    Notifiable::NotificationStatus.count.should == 1
    a_request(:post, d.token)
      .with(:body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><wp:Notification xmlns:wp=\"WPNotification\"><wp:Toast><wp:Text1></wp:Text1><wp:Text2>Test message</wp:Text2><wp:Param>?flag=true&amp;notification_id=#{n1_with_params.id}</wp:Param></wp:Toast></wp:Notification>")
      .should have_been_made.once
  end
  
  it "de-registers a device on receiving a 404 status from MPNS" do        
    stub_request(:post, d.token).to_return(:status => 404)
    
    n1.batch do |n|
      n.add_device_token(d)
    end
    
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 1
    Notifiable::DeviceToken.first.is_valid.should == false
  end
  
end