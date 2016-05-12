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

  # Returns the current logged-in user (if any).
  def current_user
    # Third version
    # This practice of evaluating || expressions from left to right and stopping on the first true value is 
    # known as short-circuit evaluation. The same principle applies to && statements, 
    # except in this case evaluation stops on the first false value.
    @current_user ||= User.find_by(id: session[:user_id])
    # find_by will hit database, so store the result of User.find_by in an instance variable.
    
    # First version
    # if @current_user.nil?
    #   @current_user = User.find_by(id: session[:user_id])
    # else
    #   @current_user
    # end

    # Second version
    # @current_user = @current_user || User.find_by(id: session[:user_id])
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
end
