ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Returns true if a test user is logged in.
  # sessions_helper is not available in test, but session method is available. 
  # Use is_logged_in? instead of logged_in? so that the test helper and Sessions helper methods have different names, 
  # which prevents them from being mistaken for each other 
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Logs in a test user.
  def log_in_as(user, options = {})
    password = options[:password] || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post login_path, session: {
        email: user.email,
        password: password,
        remember_me: remember_me
      }
    else 
      session[:user_id] = user.id
    end
  end

  private
    # Returns true inside an integration test.
    def integration_test?
      defined?(post_via_redirect)
    end
end
