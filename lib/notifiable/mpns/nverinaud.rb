require 'notifiable'
require "notifiable/mpns/nverinaud/version"
require "notifiable/mpns/nverinaud/batch"

Notifiable.notifier_classes[:mpns] = Notifiable::Mpns::Nverinaud::Batch
