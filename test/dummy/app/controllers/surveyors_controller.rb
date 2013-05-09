class SurveyorsController < ApplicationController
  # GET /surveyors
  # GET /surveyors.json
  def index
    @surveyors = Surveyor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @surveyors }
    end
  end

  # GET /surveyors/1
  # GET /surveyors/1.json
  def show
    @surveyor = Surveyor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @surveyor }
    end
  end

  # GET /surveyors/new
  # GET /surveyors/new.json
  def new
    @surveyor = Surveyor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @surveyor }
    end
  end

  # GET /surveyors/1/edit
  def edit
    @surveyor = Surveyor.find(params[:id])
  end

  # POST /surveyors
  # POST /surveyors.json
  def create
    @surveyor = Surveyor.new(params[:surveyor])

    respond_to do |format|
      if @surveyor.save
        format.html { redirect_to @surveyor, notice: 'Surveyor was successfully created.' }
        format.json { render json: @surveyor, status: :created, location: @surveyor }
      else
        format.html { render action: "new" }
        format.json { render json: @surveyor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /surveyors/1
  # PUT /surveyors/1.json
  def update
    @surveyor = Surveyor.find(params[:id])

    respond_to do |format|
      if @surveyor.update_attributes(params[:surveyor])
        format.html { redirect_to @surveyor, notice: 'Surveyor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @surveyor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /surveyors/1
  # DELETE /surveyors/1.json
  def destroy
    @surveyor = Surveyor.find(params[:id])
    @surveyor.destroy

    respond_to do |format|
      format.html { redirect_to surveyors_url }
      format.json { head :no_content }
    end
  end
  
  def display
    reset_stash if params[:reset] # for testing only
    @surveyor = Surveyor.find(params[:id])
    @surveyor.get_published
    @post = Assessing.get_post(params["id"],session)
  end
  
  def post
    @surveyor = Surveyor.find(params[:id])
    @surveyor.get_published
  
    @in = params[:post]
    results = Assessing.score_assessment(@surveyor.published_assessment,params[:post])
    Assessing.set_post(params[:id],params[:post],session)
    render :text => "Testing: post_obj =>  #{results.inspect} \n The original post #{@in.inspect}", :layout => true
  end
  
  
  private
  
  
  def reset_stash
    stash = Assessing.get_stash(session)
    stash.delete
    reset_session
  end
end
