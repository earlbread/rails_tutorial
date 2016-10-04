require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
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
  
  test "valid sign up information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: {name: "Test",
                                         email: "test@example.com",
                                         password: "foobar",
                                         password_confirmation: "foobar",} }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    
    # Invalid activation tokens.
    get edit_account_activation_path("Invalid token", email: user.email)
    assert_not is_logged_in?
    
    # Valid token, wrong email.
    get edit_account_activation_path(user.activation_token, email: "Wrong email")
    assert_not is_logged_in?
    
    # Valid activation token.
    get edit_account_activation_path(user.activation_token, email: user.email)
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
