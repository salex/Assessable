require_dependency "assessable/application_controller"

module Assessable
  class AnswersController < ApplicationController
    before_filter :load_resources, :except => :create
    
  
    # GET /answers/1
    # GET /answers/1.json
    def show
      #@answer = Answer.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @answer }
      end
    end
  
    # GET /answers/new
    # GET /answers/new.json
    def new
      max = @question.answers.maximum(:sequence) 
      @answer.sequence = max.nil? ? 1  : max + 1
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @answer }
      end
    end
  
    # GET /answers/1/edit
    def edit
      #@answer = Answer.find(params[:id])
    end
  
    # POST /answers
    # POST /answers.json
    def create
      @answer = Answer.new(params[:answer])
  
      respond_to do |format|
        if @answer.save
          format.html { redirect_to @answer, notice: 'Answer was successfully created.' }
          format.json { render json: @answer, status: :created, location: @answer }
        else
          format.html { render action: "new" }
          format.json { render json: @answer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /answers/1
    # PUT /answers/1.json
    def update
      #@answer = Answer.find(params[:id])
  
      respond_to do |format|
        if @answer.update_attributes(params[:answer])
          format.html { redirect_to @answer, notice: 'Answer was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @answer.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /answers/1
    # DELETE /answers/1.json
    def destroy
      #@answer = Answer.find(params[:id])
      @answer.destroy
  
      respond_to do |format|
        format.html { redirect_to question_url(@answer.question_id) }
        format.json { head :no_content }
      end
    end
    
    private
    
    def load_resources
      if params[:id]
        @answer = Answer.find(params[:id])
        @question = @answer.question
      elsif params[:question_id]
        @question = Question.find(params[:question_id])
        @answer = @question.answers.build
      end
    end
    
  end
end
