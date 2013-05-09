require_dependency "assessable/application_controller"

module Assessable
  class QuestionsController < ApplicationController
    before_filter :load_resources, :except => :create
  
    # GET /questions/1
    # GET /questions/1.json
    def show
      #@question = Question.find(params[:id])
      @answers = @question.answers
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @question }
      end
    end
  
    # GET /questions/new
    # GET /questions/new.json
    def new
      max = @assessment.questions.maximum(:sequence) 
      @question.sequence = max.nil? ? 1  : max + 1
      @question.answer_tag = @assessment.default_tag.blank? ? "" : @assessment.default_tag
      @question.answer_layout = @assessment.default_layout.blank? ? "" : @assessment.default_layout
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @question }
      end
    end
  
    # GET /questions/1/edit
    def edit
      #@question = Question.find(params[:id])
    end
  
    # POST /questions
    # POST /questions.json
    def create
      @question = Question.new(params[:question])
  
      respond_to do |format|
        if @question.save
          format.html { redirect_to @question, notice: 'Question was successfully created.' }
          format.json { render json: @question, status: :created, location: @question }
        else
          format.html { render action: "new" }
          format.json { render json: @question.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /questions/1
    # PUT /questions/1.json
    def update
      #@question = Question.find(params[:id])
      respond_to do |format|
        if @question.update_attributes(params[:question])
          format.html { redirect_to @question, notice: 'Question was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @question.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /questions/1
    # DELETE /questions/1.json
    def destroy
      #@question = Question.find(params[:id])
      @question.destroy
  
      respond_to do |format|
        format.html { redirect_to assessment_path(@question.assessment_id) }
        format.json { head :no_content }
      end
    end
    
    def edit_answers
      @question = Question.find(params[:id])
      max = @question.answers.maximum(:sequence) 
      seq = max.nil? ? 0  : max 
      cnt = @question.answers.count > 0 ? 2 : 5
      cnt.times do
        seq += 1
        answer = @question.answers.build({:sequence => seq})
      end
      #render :text => params.inspect, :layout => true
    end
    
    def clone
      clone_question = Question.find(params[:id])
      @question = clone_question.clone
      redirect_to  edit_question_url(@question)
    end
    
    
    private
    
    def load_resources
      if params[:id]
        @question = Question.find(params[:id])
        @assessment = @question.assessment
      elsif params[:assessment_id]
        @assessment = Assessment.find(params[:assessment_id])
        @question = @assessment.questions.build
      end
    end
  end
end
