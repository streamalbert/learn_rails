class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # 12.2.5 Using remote: true in _follow.html.erb tells Rails to use Ajax and allow the form to be handled by JavaScript
    # By using a simple HTML property instead of inserting the full JavaScript code 
    # (as in previous versions of Rails), Rails follows the philosophy of unobtrusive JavaScript.
    # To respond to Ajax requests. We can use the respond_to method, responding appropriately depending on the type of request
    respond_to do |format|
      format.html { redirect_to @user }
      # In the case of an Ajax request, Rails automatically calls a JavaScript embedded Ruby (.js.erb) 
      # file with the same name as the action, i.e., create.js.erb or destroy.js.erb. As you might guess, 
      # such files allow us to mix JavaScript and embedded Ruby to perform actions on the current page.
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

end
