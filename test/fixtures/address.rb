class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true
  
  named_scope :in_range, lambda {|lat, lng, zip_code| 
    {:conditions => 
    "(
      (POW(addresses.radius,2) >= 
        (POW(69.1*(#{lat}-addresses.lat),2) + 
          POW(69.1*(#{lng}-addresses.lng) * cos(#{lat} / 57.3), 2)
        )
      )
      OR (addresses.zip = '#{zip_code}')
     )"
  }}
end