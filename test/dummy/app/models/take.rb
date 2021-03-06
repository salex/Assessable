# Take is an example of how to use Assessable in a poloymophic Assessor, Assessed, Score, {by} environment

class Take
  attr_accessor  :stash, :taking, :assessed, :assessor, :section, :post
  
  def initialize(session,clear=false)
    ## Get or create a Stash instance by session_id
    @stash = Assessing.get_stash(session)
    if clear
      @stash.data = nil
      @stash.session = {'user_id' => session['user_id']}
      @stash.save
    end
  end
  
  def common_setup(controller,assessor,assessed,options)
    ## Setup and session with control information
    # taking is a mini-controller for the take process.
    # some fields are used by the Take class, others may be used by the controller or Score model.
    # i.e., an after_method progression.rollup would be called passing take, which should contain all the info needed 
    # to rollup scores and set progressions status, etc
    opt = options.stringify_keys
    @assessed = assessed
    @assessor = assessor
    # if section.id is passes in option, only that section is fetched
    if opt["section"]
      @sections = @assessor.assessor_sections.where(:status => "active", id:  opt["section"]).where("model_method is NULL")
    else
      @sections = @assessor.assessor_sections.where(:status => "active").where("model_method is NULL")
    end
    # model_methods are not scored by take, but buy the take controller, this sets up what needs to be scored
    model_methods = @assessor.assessor_sections.where(:status => "active").where("model_method NOT NULL")
    
    @taking = {"controller" => controller}
    # Itmes from assessor
    @taking["repeating"] = @assessor.repeating # repeating assessors do not look for old posts
    @taking["before"] = @assessor.before_method
    @taking["after"] = @assessor.after_method
    @taking["by_user"] = @stash.session['user_id'] # current user
    @taking["assessor_id"] = @assessor.id
    # Items from sections
    @taking["sections"] = @sections.pluck(:id)
    @taking["names"] = @sections.pluck(:name)
    @taking["max"] = @sections.pluck(:max) # used in setting score.scoring for survey
    @taking["models"] = model_methods.pluck(:id) unless model_methods.empty?
    @taking["assessed_type"] = @assessed.class.name
    @taking["assessed_id"] = @assessed.id
    # set up initial parameters
    @taking["status"] = Array.new(@taking["sections"].count) 
    @taking["complete"] = false
    @taking['can_take'] = can_take? if @taking["before"] # call before hook
    @taking["idx"] = 0
    @stash.session["taking"] = @taking
    @stash.save
    return self
  end
  
  def apply_setup(assessor,assessed,options={})
    return common_setup("apply",assessor,assessed,options)
  end
  
  def score_setup(assessor,assessed,options={})
    return common_setup("score",assessor,assessed,options)
  end
  
  def evaluate_setup(assessor,assessed,options={})
    return common_setup("evaluate",assessor,assessed,options)
  end
  
  def survey_setup(assessor,options={})
    assessed = User.where(:role => "Guest").first
    return common_setup("survey",assessor,assessed,options)
  end
  
  
  def get_section
    # it will get the current session using an index into the sections array
    # it will get the post out of the stash, if there (revisit) or,
    # it will try to get a post from a previouse score, unless it is repeating
    
    @taking = @stash.session["taking"]
    @section = AssessorSection.find(@taking["sections"][@taking["idx"]])
    @post = @stash.get_post(@taking["sections"][@taking["idx"]])
    if !@taking['repeating'] && @post.nil?
      # if not repeating assessment (e.g. annual evalution) look for previous score
      assessed = get_assessed
      score = assessed.scores.where(:assessor_section_id => @taking["sections"][@taking["idx"]]).first
      unless score.nil?
        @post = score.scoring
      end
    end
    return self
  end
  
  def set_post(post)
    @taking = @stash.session["taking"]
    @section = AssessorSection.find(@taking["sections"][@taking["idx"]])
    post = Assessing.score_assessment(@section.published,post).scored_post
    post_idx = @taking["idx"]
    @taking["status"][@taking["idx"]] = true
    new_idx = @taking["status"].index(nil)
    @taking["idx"]  = new_idx
    @taking["complete"] = new_idx.nil?
    @stash.session["taking"] = @taking
    @stash = @stash.set_post(@taking["sections"][post_idx],post) # saves stash
    return @taking["complete"]
  end
  
  def get_assessed
    @taking = @stash.session["taking"]
    assessed_model = @taking["assessed_type"].constantize
    assessed_id = @taking["assessed_id"]
    assessed = assessed_model.find(assessed_id)
  end
  
  def self.rescore_assessor(assessor) # assessor instance
    sections = assessor.assessor_sections.where("status LIKE ? ", "active.input")
    sections.each do |section|
      scores = section.scores
      scores.each do |score|
        post = Assessing.score_assessment(section.published, score.scoring).scored_post
        score.scoring = post
        score.save
      end
    end
  end
  
  def self.rescore_section(section) # session instance
    scores = section.scores
    scores.each do |score|
      post = Assessing.score_assessment(section.published, score.scoring).scored_post
      score.scoring = post
      score.save
    end
  end
  
  # This is envisioned as a front end to either ability calls or model calls (e.g., application can't be modified')
  def can_take?
    return send("can_#{@taking['controller']}?")
  end
  
  def can_apply?
    true
  end
  def can_survey?
    true
  end
  def can_score?
    true
  end
  def can_evaluate?
    true
  end
  
end