class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase

    if user&.authenticate params[:session][:password]
      log_in user
      if params[:session][:remember_me] == Settings.checkbox_checked
        remember user
      else
        forget user
      end
      flash[:success] = t ".login_successfully"
      redirect_to user
    else
      flash.now[:danger] = t ".invalid_credentials"
      render :new
    end
  end

  def destroy
    log_out if logged_in?

    redirect_to root_url
  end
end
