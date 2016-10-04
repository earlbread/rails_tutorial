class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    activation_token = params[:id]
    
    if user && !user.activated? && user.authenticated?(:activation, activation_token)
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
