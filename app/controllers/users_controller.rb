class UsersController < ApplicationController
  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".fail_message"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t ".welcome_message"
      log_in @user
      redirect_to @user
    else
      flash[:danger] = t ".fail_message"
      render signup_path
    end
  end

  private

  def user_params
    params.require(:user).permit User::USERS_PARAMS
  end
end
