class AssessorSectionsController < ApplicationController

  # GET /assessor_sections/1
  # GET /assessor_sections/1.json
  before_filter :check_for_new, :only => :show
  def show
    @assessor_section = AssessorSection.find(params[:id])
    @scores = @assessor_section.scores
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assessor_section }
    end
  end

  # GET /assessor_sections/new
  # GET /assessor_sections/new.json
  def new
    if params[:assessment_id]
      max = Assessor.find(params[:assessor_id]).assessor_sections.maximum(:sequence)       
      @assessor_section = AssessorSection.new(:assessor_id => params[:assessor_id], :assessment_id => params[:assessment_id])
      @assessor_section.sequence = max
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @assessor_section }
      end
    else
      list
      #redirect_to root_path, :alert => "Assessor Sections cannot be created without a linking Assessment"
    end
  end

  # GET /assessor_sections/1/edit
  def edit
    @assessor_section = AssessorSection.find(params[:id])
  end

  # POST /assessor_sections
  # POST /assessor_sections.json
  def create
    @assessor_section = AssessorSection.new(params[:assessor_section])
    
    respond_to do |format|
      if @assessor_section.save
        @assessor_section.get_published
        @assessor_section.save
        format.html { redirect_to @assessor_section, notice: 'Assessor section was successfully created.' }
        format.json { render json: @assessor_section, status: :created, location: @assessor_section }
      else
        format.html { render action: "new" }
        format.json { render json: @assessor_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assessor_sections/1
  # PUT /assessor_sections/1.json
  def update
    @assessor_section = AssessorSection.find(params[:id])
    @assessor_section.assign_attributes(params[:assessor_section])
    publish_or_clone if params[:stale]
    respond_to do |format|
      if @assessor_section.save
        format.html { redirect_to @assessor_section, notice: 'Assessor section was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessor_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assessor_sections/1
  # DELETE /assessor_sections/1.json
  def destroy
    @assessor_section = AssessorSection.find(params[:id])
    @assessor_section.destroy

    respond_to do |format|
      format.html { redirect_to assessor_path(@assessor_section) }
      format.json { head :no_content }
    end
  end
  
  def list
    @assessor = Assessor.find(params[:assessor_id] ||= params[:id])
    @assessments = @assessor.assessment_search(params)
    render :template => "assessor_sections/list"
  end
  
  def search
    @assessor = Assessor.find(params[:id])
    @assessments = @assessor.assessment_search(params)
    render :template => "assessor_sections/list"
  end
  
  def rescore
    section = AssessorSection.find(params[:id])
    result = Take.rescore_section(section)
    if result
      redirect_to section, notice: "Assessor rescored"
    else
      redirect_to section, alert: "Rescoring failed "
    end
  end
  
  private
  
  def publish_or_clone
    #TODO move to model
    if params[:stale]
      if params[:stale] == "publish"
        @assessor_section.get_published 
        #@assessor_section.save
      end
      if params[:stale] == "clone"
        old = @assessor_section
        @assessor_section = old.dup
        @assessor_section.get_published
        #@assessor_section.save
        old.status = old.status.gsub("active","archived")
        old.save
      end
    end
  end
  
  def check_for_new
    redirect_to root_path, :alert => "Assessor Sections cannot be created without a linking Assessment" if params[:id] == "new"
  end
end
