require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "",
                               email: "user@invalid",
                               password: "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      # we’ve used the post_via_redirect variant to post to the users path. 
      # This simply arranges to follow the redirect after submission, resulting in a rendering of the ’users/show’ template.
      post_via_redirect users_path, user: { name: "example user",
                                            email: "user@example.com",
                                            password: "123456",
                                            password_confirmation: "123456" }
    end
    assert_template 'users/show'
    assert is_logged_in?
  end
end
