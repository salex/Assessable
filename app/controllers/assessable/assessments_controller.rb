require_dependency "assessable/application_controller"

module Assessable
  class AssessmentsController < ApplicationController
    # GET /assessments
    # GET /assessments.json
    def index
      @assessments = Assessment.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @assessments }
      end
    end
  
    # GET /assessments/1
    # GET /assessments/1.json
    def show
      @assessment = Assessment.find(params[:id])
      @questions = @assessment.questions
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @assessment }
      end
    end
  
    # GET /assessments/new
    # GET /assessments/new.json
    def new
      @assessment = Assessment.new(status: "New")
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @assessment }
      end
    end
  
    # GET /assessments/1/edit
    def edit
      @assessment = Assessment.find(params[:id])
    end
  
    # POST /assessments
    # POST /assessments.json
    def create
      @assessment = Assessment.new(params[:assessment])
  
      respond_to do |format|
        if @assessment.save
          format.html { redirect_to @assessment, notice: 'Assessment was successfully created.' }
          format.json { render json: @assessment, status: :created, location: @assessment }
        else
          format.html { render action: "new" }
          format.json { render json: @assessment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /assessments/1
    # PUT /assessments/1.json
    def update
      @assessment = Assessment.find(params[:id])
  
      respond_to do |format|
        if @assessment.update_attributes(params[:assessment])
          format.html { redirect_to @assessment, notice: 'Assessment was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @assessment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /assessments/1
    # DELETE /assessments/1.json
    def destroy
      @assessment = Assessment.find(params[:id])
      @assessment.destroy
  
      respond_to do |format|
        format.html { redirect_to assessments_url }
        format.json { head :no_content }
      end
    end
    
    ## test methods 
    
    def display
      reset_stash if params[:reset] # for testing only
      @assessment = Assessment.find(params[:id])
      @post = Stash.get_post(params["id"],session)
      @assessment_hash = Assessment.publish(params[:id])
    end
    
    def post
      @assessment_hash = Assessment.publish(params[:id])
      @post = Assessing.score_assessment(@assessment_hash,params[:post])
      Stash.set_post(params[:id],params[:post],session)
      #render :text => "Testing: post_obj =>  #{results.inspect} \n The original post #{@in.inspect}", :layout => true
    end
    
    def clone
      clone_assessment = Assessment.find(params[:id])
      @assessment = clone_assessment.clone
      redirect_to  edit_assessment_url(@assessment)
    end
    
    
    
    private
    
    
    def reset_stash
      stash = Stash.get(session)
      stash.delete
      reset_session
    end
    
  end
end
