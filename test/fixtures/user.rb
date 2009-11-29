class User < ActiveRecord::Base
  has_many :posts
  has_many :addresses, :as => :addressable
  
  named_scope :active, :conditions=>'users.active=1'
  named_scope :has_status, lambda{|status| {:conditions=>["users.status=?", status]}}
  named_scope :has_posts_for_month, lambda{|month|
    {:association=>{:source=>:posts, :scope=>[:published_in_month, month]}}
  }
  named_scope :has_approved_posts, {:association=>{:source=>:posts, :scope=>:approved}}
  named_scope :has_approved_posts_without_source, {:association=>{:scope=>:approved}}
  named_scope :has_approved_posts_without_scope, {:association=>{:source=>:posts}}
end