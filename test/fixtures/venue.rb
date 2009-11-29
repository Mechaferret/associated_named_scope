class Venue < ActiveRecord::Base
  has_many :addresses, :as => :addressable
  
  named_scope :within_range, lambda{|address|
    {:association=>{:source=>:addresses, :scope=>[:in_range, address.lat, address.lng, address.zip]}}
  }
  named_scope :rating_higher_than, lambda{|rating| {:conditions=>["venues.rating>=?", rating]}}
  
end