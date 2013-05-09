class TakeController < ApplicationController
 
  def apply
    taking = Take.new(session,true)
    @assessor = Assessor.find(params[:id])
    @taking = taking.apply_setup(@assessor,current_user,method: :can_take)
    render :template => "take/show"
    
  end
  
  def score
    taking = Take.new(session,true)
    @assessor = Assessor.find(params[:id])
    assess = params[:assessed].capitalize.constantize
    @assessed = assess.find(params[:assessed_id])
    @taking = taking.score_setup(@assessor,@assessed,current_user,method: :can_eval, section: params[:section])
    section
  end
  
  def evaluate
    taking = Take.new(session,true)
    @assessor = Assessor.find(params[:id])
    assess = params[:assessed].capitalize.constantize
    @assessed = assess.find(params[:assessed_id])
    @taking = taking.evaluate_setup(@assessor,@assessed,current_user,method: :can_eval, section: params[:section])
    section
  end
  
  
  def survey
    taking = Take.new(session,true)
    @assessor = Assessor.find(params[:id])
    @taking = taking.survey_setup(@assessor,current_user,section: params[:section])
    section
  end

  def section
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
    taking =  Take.new(session)
    @info = taking.stash.session["taking"]
    # logger.debug "CALLin render complete #{@apply}"
    render :template => "take/complete"
    
  end
  
  def finish
    taking =  Take.new(session)
    if taking.stash.session["taking"]["models"]
      taking = taking.get_assessed.model_score(taking) unless taking.stash.session["taking"]["models"].empty?
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
