require 'notifiable'
require "notifiable/mpns/nverinaud/version"
require "notifiable/mpns/nverinaud/single_notifier"

Notifiable.notifier_classes[:mpns] = Notifiable::Mpns::Nverinaud::SingleNotifier
