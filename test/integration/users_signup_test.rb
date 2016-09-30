require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid sign up information" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: { user: {name: "",
                                        email: "user@invalid",
                                        password: "foo",
                                        password_confirmation: "bar",} }
    end
    assert_template 'users/new'
    assert_select 'form[action="/signup"]'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_select 'li', "Name can't be blank"
    assert_select 'li', "Email is invalid"
    assert_select 'li', "Password is too short (minimum is 6 characters)"
    assert_select 'li', "Password confirmation doesn't match Password"
  end
  
  test "valid sign up information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post signup_path, params: { user: {name: "Test",
                                         email: "test@example.com",
                                         password: "foobar",
                                         password_confirmation: "foobar",} }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert_select 'div.alert-success', "Welcome to the Sample App"
  end
end
