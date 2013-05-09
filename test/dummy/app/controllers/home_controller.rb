class HomeController < ApplicationController
  def index
    session[:user_id] = User.first.id if current_user.nil?
  end
end