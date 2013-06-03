class TakeController < ApplicationController
 
  def apply
    ## Called from a list of available job applications
    taking = Take.new(session,true)
    @assessor = Assessor.find(params[:id])
    @taking = taking.apply_setup(@assessor,current_user,method: :can_take)
    render :template => "take/show"
    
  end
  
  def score
    ## Called from a model instance where current user is scoring something for that instance
    taking = Take.new(session,true)
    @assessor = Assessor.find(params[:id])
    assess = params[:assessed].capitalize.constantize
    @assessed = assess.find(params[:assessed_id])
    @taking = taking.score_setup(@assessor,@assessed,method: :can_eval, section: params[:section])
    section
  end
  
  def evaluate
    ## Called from a model instance where current user is scoring something for that instance
    taking = Take.new(session,true)
    @assessor = Assessor.find(params[:id])
    assess = params[:assessed].capitalize.constantize
    @assessed = assess.find(params[:assessed_id])
    @taking = taking.evaluate_setup(@assessor,@assessed)    
    section
  end
  
  
  def survey
    ## Called from a guest user
    taking = Take.new(session,true)
    @assessor = Assessor.find(params[:id])
    @taking = taking.survey_setup(@assessor,section: params[:section])
    section
  end

  def section
    ## multi-form steps, all Assessors have at least one section/step
    init =  Take.new(session)
    if params[:id].include?('back')
      init.stash.session["taking"]["idx"] = params[:id].to_i
      init.stash.save
    end
    @taking = init.get_section
    @post = @taking.post
    @info = @taking.stash.session["taking"]
    @published = @taking.section.published
    render :template => "take/section"
  end
  
  def post
    ## Store the post in stash and go to next step, a review page and finish
    @taking =  Take.new(session)
    finished = @taking.set_post(params[:post])
    if finished
      if @taking.stash.session["taking"]["sections"].count == 1
        finish
      else
        complete
      end
    else
      section
    end
  end
  
  def complete
    # a review page that has links to go back to sections
    taking =  Take.new(session)
    @info = taking.stash.session["taking"]
    render :template => "take/complete"
    
  end
  
  def finish
    ## Store the final results form the stash and return
    taking =  Take.new(session)
    if taking.stash.session["taking"]["models"] && !taking.taking["models"].empty?
      assessed = taking.get_assessed
      taking = assessed.model_score(taking) 
    end
    if taking.stash.session["taking"]["controller"] == "survey"
      Score.post_survey(taking.stash)
    else
      Score.post_scores(taking.stash)
    end
    what =  taking.stash.session["taking"]
    Assessing.clear_stash(session)
    redirect_to root_path, :notice => "You be done with the #{what["controller"]} #{what}"
  end
  
  def cancel
    what =  Take.new(session).stash.session["taking"]["controller"]
    Assessing.clear_stash(session)
    redirect_to root_path, :notice => "Canceled taking the #{what}. You can always try later."
  end
end
