require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:test_user01)
    @non_admin = users(:test_user02)
    @non_activated_user = users(:chap11_3_non_activated)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do | user |
      unless user == @non_activated_user
        assert_select 'a[href=?]', user_path(user), text: user.name
        unless user == @admin
          assert_select 'a[href=?]', user_path(user), text: 'delete'
        end
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  #test "index including pagination" do
  #  log_in_as(@user)
  #  get users_path
  #  assert_template 'users/index'
  #  assert_select 'div.pagination', count: 2
  #  User.paginate(page: 1).each do | user |
  #    assert_select 'a[href=?]', user_path(user), text: user.name
  #  end
  #end
  test "should not allow the not activated attribute" do
    log_in_as(@non_activated_user)
    assert_not @non_activated_user.activated?
    get users_path
    assert_select "a[href=?]", user_path(@non_activated_user), count:0
    get user_path(@non_activated_user)
    assert_redirected_to root_url
  end
end
