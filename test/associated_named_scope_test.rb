require 'test_helper'

class AssociatedNamedScopeTest < ActiveSupport::TestCase
  test "normal named_scope with no arguments still works" do
    active_users = User.active
    assert active_users.size==4
    assert active_users.include?(users(:los_angeles))
    assert active_users.include?(users(:santa_monica))
    assert active_users.include?(users(:new_york))
    assert active_users.include?(users(:austin))
  end
  
  test "normal named_scope with arguments still works" do
    gurus = User.has_status('Guru')
    assert gurus.size==3
    assert gurus.include?(users(:los_angeles))
    assert gurus.include?(users(:austin))
    assert gurus.include?(users(:san_francisco))
  end
  
  test "normal named_scope on class not calling has_associated_named_scope still works" do
    la = Address.in_range(34.05, -118.45, '90025')
    assert la.size==6
    assert la.include?(addresses(:la_1))
    assert la.include?(addresses(:la_2))
    assert la.include?(addresses(:sm_1))
    assert la.include?(addresses(:echo_park))
    assert la.include?(addresses(:silverlake))
    assert la.include?(addresses(:weho))
  end
  
  test "one level associated_named_scope with no arguments works" do
    approved = User.has_approved_posts
    assert approved.size==3
    assert approved.include?(users(:los_angeles))
    assert approved.include?(users(:santa_monica))
    assert approved.include?(users(:austin))
  end
  
  test "one level associated_named_scope with arguments works" do
    november = User.has_posts_for_month(11)
    assert november.size==3
    assert november.include?(users(:los_angeles))
    assert november.include?(users(:santa_monica))
    assert november.include?(users(:austin))
    silverlake = Venue.within_range(addresses(:silverlake))
    assert silverlake.size==2
    assert silverlake.include?(venues(:spaceland))
    assert silverlake.include?(venues(:roxy))
  end
  
  test "two level associated_named_scope with arguments works" do
    laposts = Post.within_range(addresses(:la_1))
    assert laposts.size==3
    assert laposts.include?(posts(:la_first))
    assert laposts.include?(posts(:sm_first))
    assert laposts.include?(posts(:la_last))
  end
  
  test "chaining associated scopes works" do
    approved_la_posts = Post.within_range(addresses(:la_1)).approved
    assert approved_la_posts.size==2
    assert approved_la_posts.include?(posts(:la_first))
    assert approved_la_posts.include?(posts(:sm_first))
    november_gurus = User.has_posts_for_month(11).has_status('Guru')
    assert november_gurus.size==2
    assert november_gurus.include?(users(:los_angeles))
    assert november_gurus.include?(users(:austin))
  end
  
  test "missing source and scope exceptions work" do
    assert_raise(ActiveRecord::NamedScope::AssociatedNamedScope::UndefinedAssociationOption) {
      User.has_approved_posts_without_source
    }
    assert_raise(ActiveRecord::NamedScope::AssociatedNamedScope::UndefinedAssociationOption) {
      User.has_approved_posts_without_scope
    }
  end
    
end

