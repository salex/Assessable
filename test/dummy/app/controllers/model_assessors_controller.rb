class ModelAssessorsController < ApplicationController
  # GET /model_assessors
  # GET /model_assessors.json
  def index
    @model_assessors = ModelAssessor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @model_assessors }
    end
  end

  # GET /model_assessors/1
  # GET /model_assessors/1.json
  def show
    @model_assessor = @assessoring = ModelAssessor.find(params[:id])
    @assessors = @model_assessor.assessors

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @model_assessor }
    end
  end

  # GET /model_assessors/new
  # GET /model_assessors/new.json
  def new
    @model_assessor = ModelAssessor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @model_assessor }
    end
  end

  # GET /model_assessors/1/edit
  def edit
    @model_assessor = ModelAssessor.find(params[:id])
  end

  # POST /model_assessors
  # POST /model_assessors.json
  def create
    @model_assessor = ModelAssessor.new(params[:model_assessor])

    respond_to do |format|
      if @model_assessor.save
        format.html { redirect_to @model_assessor, notice: 'Model assessor was successfully created.' }
        format.json { render json: @model_assessor, status: :created, location: @model_assessor }
      else
        format.html { render action: "new" }
        format.json { render json: @model_assessor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /model_assessors/1
  # PUT /model_assessors/1.json
  def update
    @model_assessor = ModelAssessor.find(params[:id])

    respond_to do |format|
      if @model_assessor.update_attributes(params[:model_assessor])
        format.html { redirect_to @model_assessor, notice: 'Model assessor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @model_assessor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /model_assessors/1
  # DELETE /model_assessors/1.json
  def destroy
    @model_assessor = ModelAssessor.find(params[:id])
    @model_assessor.destroy

    respond_to do |format|
      format.html { redirect_to model_assessors_url }
      format.json { head :no_content }
    end
  end
  
  # non-CRUD
  
  def new_assessor
    @assessoring = ModelAssessor.find(params[:id])
    @assessor = @assessoring.assessors.build(:assessed_model => @assessoring.assessed_model, status: "New")
    respond_to do |format|
      format.html {render :template => "assessors/new"}
      format.json { render json: @assessor }
    end
  end
  
end
