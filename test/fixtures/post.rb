class Post < ActiveRecord::Base
  belongs_to :user
  
  named_scope :approved, :conditions => "posts.approved=1"
  named_scope :within_range, lambda{|address|
    {:association=>{:source=>{:user=>:addresses}, :scope=>[:in_range, address.lat, address.lng, address.zip]}}
  }
  named_scope :published_in_month, lambda{|month| {:conditions=>["month(posts.publication_date)=?", month]}}
end