module SessionsHelper

  # Logs in the given user
  def log_in(user)
    # session method provided by Rails, can be treated as if it were a hash.
    session[:user_id] = user.id
    # This places a temporary cookie on the user’s browser containing an encrypted version of the user’s id, 
    # which allows us to retrieve the id on subsequent pages using session[:user_id]. 
    # In contrast to the persistent cookie created by the cookies method, 
    # the temporary cookie created by the session method expires immediately when the browser is closed.

    # Because temporary cookies created using the session method are automatically encrypted, 
    # the code is secure, and there is no way for an attacker to use the session information to log in as the user. 
    # This applies only to temporary sessions initiated with the session method, though, 
    # and is not the case for persistent sessions created using the cookies method. 
    # Permanent cookies are vulnerable to a session hijacking attack. 
  end

  # Remembers a user in a persistent session
  def remember(user)
    user.remember

    # Because using: cookies[:user_id] = user.id, it places the id as plain text, this method exposes the form of the application’s cookies 
    # and makes it easier for an attacker to compromise user accounts. 
    # To avoid this problem, we’ll use a signed cookie, which securely encrypts the cookie before placing it on the browser
    # permanent is short for 20.years.from_now.utc, refer to tutorial 8.4.2
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Forgets a persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Returns the current logged-in user (if any).
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Third version
  # This practice of evaluating || expressions from left to right and stopping on the first true value is 
  # known as short-circuit evaluation. The same principle applies to && statements, 
  # except in this case evaluation stops on the first false value.
  
  # @current_user ||= User.find_by(id: session[:user_id])
  
  # find_by will hit database, so store the result of User.find_by in an instance variable.
  
  # First version
  # if @current_user.nil?
  #   @current_user = User.find_by(id: session[:user_id])
  # else
  #   @current_user
  # end

  # Second version
  # @current_user = @current_user || User.find_by(id: session[:user_id])

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
end
