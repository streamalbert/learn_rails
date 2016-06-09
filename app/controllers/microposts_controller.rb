class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # This corresponds to HTTP_REFERER, as defined by the specification for HTTP. 
    # Note that “referer” is not a typo—the word is actually misspelled in the spec. 
    # Rails corrects this error by writing “referrer” instead.
    # request.referrer is the previous URL, using request.referrer we arrange to redirect back to the page issuing the delete request
    redirect_to request.referrer || root_url
  end

  private 

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
