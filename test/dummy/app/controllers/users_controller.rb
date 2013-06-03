class UsersController < ApplicationController
  def index
    @users = User.all
    setup if @users.empty?
  end
  
  def show
    @user = User.find(params[:id])
    session[:user_id] = @user.id if params[:login]
    if params[:score]
      redirect_to score_stages_path(:assessed => "user", :assessed_id => @user.id)
    elsif params[:evaluate]
      redirect_to evaluate_stages_path(:assessed => "instructor", :assessed_id => 1)
    elsif params[:survey]
      redirect_to survey_stages_path(:assessed => "user", :assessed_id => @user.id)
    end
    @scores = @user.scores
    @users = User.all
    
  end
  
  private
  def setup
    users = [%w(One Guest),%w(Two Citizen), %w(Three Employee), %w(Four Instructor)]
    users.each do |user|
      User.create(:username => user[0], :role => user[1])
    end
    @users = User.all
  end
  
end
