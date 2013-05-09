class AssessorsController < ApplicationController
  # GET /assessors
  # GET /assessors.json
  def index
    @assessors = Assessor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assessors }
    end
  end

  # GET /assessors/1
  # GET /assessors/1.json
  def show
    @assessor = Assessor.find(params[:id])
    @assessor_sections = @assessor.assessor_sections
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assessor }
    end
  end

  # GET /assessors/new
  # GET /assessors/new.json
  def new
    @assessor = Assessor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assessor }
    end
  end

  # GET /assessors/1/edit
  def edit
    @assessor = Assessor.find(params[:id])
  end

  # POST /assessors
  # POST /assessors.json
  def create
    @assessor = Assessor.new(params[:assessor])

    respond_to do |format|
      if @assessor.save
        format.html { redirect_to @assessor, notice: 'Assessor was successfully created.' }
        format.json { render json: @assessor, status: :created, location: @assessor }
      else
        format.html { render action: "new" }
        format.json { render json: @assessor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assessors/1
  # PUT /assessors/1.json
  def update
    @assessor = Assessor.find(params[:id])

    respond_to do |format|
      if @assessor.update_attributes(params[:assessor])
        format.html { redirect_to @assessor, notice: 'Assessor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assessors/1
  # DELETE /assessors/1.json
  def destroy
    @assessor = Assessor.find(params[:id])
    @assessor.destroy

    respond_to do |format|
      format.html { redirect_to assessors_url }
      format.json { head :no_content }
    end
  end
  
  def rescore
    assessor = Assessor.find(params[:id])
    result = Take.rescore_assessor(assessor)
    if result
      redirect_to assessor, notice: "Assessor rescored"
    else
      redirect_to assessor, alert: "Recoring failed "
    end
  end
  
end
