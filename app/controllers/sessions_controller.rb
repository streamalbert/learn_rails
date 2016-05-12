class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      # Rails automatically converts this to the route for the user’s profile page: user_url(user)
      redirect_to user
    else
      # flash.now, specifically designed for displaying flash messages on rendered pages. 
      # Unlike the contents of flash, the contents of flash.now disappear as soon as there is an additional request
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
  end
end
