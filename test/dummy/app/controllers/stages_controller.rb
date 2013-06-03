class StagesController < ApplicationController
  def index
    @stages = Stage.all
    if @stages.empty?
      %w(One Two Three).each do |n|
        Stage.create(:name => n)
      end
      @stages = Stage.all
    end
  end
  
  def show
    @stage = @assessoring = Stage.find(params[:id])
    @assessors = @stage.assessors
    @scores = @stage.scores
  end
  
  # non-CRUD
  
  def new_assessor
    @assessoring = Stage.find(params[:id])
    @assessor = @assessoring.assessors.build(:assessed_model => "User", status: "New")
    respond_to do |format|
      format.html {render :template => "assessors/new"}
      format.json { render json: @assessor }
    end
  end
  
  def apply
    @assessors = Assessor.where(:assessoring_type => "Stage", :status => "active.apply")
    @status = "active.apply"
    render :template => "stages/assessors"
  end
  def evaluate
    @assessors = ModelAssessor.where(:assessed_model => "Instructor").first.assessors.where( :status => "active.evaluate")
    @status = "active.evaluate"
    render :template => "stages/assessors"
  end
  def score
    @assessors = Assessor.where(:assessoring_type => "Stage", :status => "active.score")
    @status = "active.score"
    render :template => "stages/assessors"
  end
  def survey
    @assessors = Assessor.where(:assessoring_type => "Stage", :status => "active.survey")
    @status = "active.survey"
    render :template => "stages/assessors"
  end
  
    
end
