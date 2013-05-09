class Take
  attr_accessor  :stash, :session, :assessed, :assessor, :section, :post
  
  def initialize(session,clear=false)
    self.stash = Assessing.get_stash(session)
    if clear
      @stash.data = nil
      @stash.session = {}
    end
  end
  
  def common_setup(assessor,assessed,options)
    opt = options.stringify_keys
    @assessed = assessed
    @assessor = assessor
    if opt["section"]
      @sections = @assessor.assessor_sections.where(:status => "active.#{@session["controller"]}", id:  opt["section"])
    else
      @sections = @assessor.assessor_sections.where(:status => "active.#{@session["controller"]}")
    end
    @session["assessor_id"] = @assessor.id
    @session["sections"] = @sections.pluck(:id)
    @session["names"] = @sections.pluck(:name)
    @session["status"] = Array.new(@session["sections"].count)
    @session["assessed_type"] = @assessed.class.name
    @session["assessed_id"] = @assessed.id
    @session["complete"] = false
    @session["idx"] = 0
    return opt
  end
  
  def apply_setup(assessor,assessed,options={})
    @session = {"controller" => "apply"}
    opt = common_setup(assessor,assessed,options)
    @session["models"] = @assessor.assessor_sections.where(:status => "active.model").pluck(:id)
    @stash.session["taking"] = @session
    ## singlescore see if has score and put score.scoring["post"] into stash,data
    @stash.save
    if  opt["method"]
      @session["can_do"] = @assessed.send( opt["method"],@assessor)
    end
    return self
  end
  
  def score_setup(assessor,assessed,by,options={})
    @session = {"controller" => "score"}
    @by = by
    opt = common_setup(assessor,assessed,options)
    @stash.session["taking"] = @session
    ## singlescore see if has score and put score.scoring["post"] into stash,data
    @stash.save
    if opt["method"]
      @session["can_do"] = @assessed.send(method,@assessor)
    end
    return self
  end
  
  def evaluate_setup(assessor,assessed,by,options={})
    @session = {"controller" => "evaluate"}
    @by = by
    opt = common_setup(assessor,assessed,options)
    @stash.session["taking"] = @session
    ## singlescore see if has score and put score.scoring["post"] into stash,data
    @stash.save
    if opt["method"]
      @session["can_do"] = @assessed.send(method,@assessor)
    end
    return self
  end
  
  def survey_setup(assessor,by,options={})
    assessed = User.where(:role => "Guest").first
    @session = {"controller" => "survey"}
    @by = by
    opt = common_setup(assessor,assessed,options)
    @session["max"] = @sections.pluck(:max)
    @stash.session["taking"] = @session
    ## singlescore see if has score and put score.scoring["post"] into stash,data
    @stash.save
    return self
  end
  
  
  def get_section
    taking = @stash.session["taking"]
    @section = AssessorSection.find(taking["sections"][taking["idx"]])
    @post = @stash.get_post(taking["sections"][taking["idx"]])
    if @post.nil?
      assessed = get_assessed
      score = assessed.scores.where(:assessor_section_id => taking["sections"][taking["idx"]]).first
      unless score.nil?
        @post = score.scoring
      end
    end
    return self
  end
  
  def set_post(post)
    taking = @stash.session["taking"]
    @section = AssessorSection.find(taking["sections"][taking["idx"]])
    post = Assessing.score_assessment(@section.published,post)
    post_idx = taking["idx"]
    taking["status"][taking["idx"]] = true
    new_idx = taking["status"].index(nil)
    taking["idx"]  = new_idx
    taking["complete"] = new_idx.nil?
    @stash.session["taking"] = taking
    @stash = @stash.set_post(taking["sections"][post_idx],post) # saves stash
    return taking["complete"]
  end
  
  def get_assessed
    taking = @stash.session["taking"]
    assessed_model = taking["assessed_type"].constantize
    assessed_id = taking["assessed_id"]
    assessed = assessed_model.find(assessed_id)
  end
  
  def self.rescore_assessor(assessor)
    sections = assessor.assessor_sections.where("status LIKE ? ", "active.input")
    sections.each do |section|
      scores = section.scores
      scores.each do |score|
        post = Assessing.score_assessment(section.published, score.scoring)
        score.scoring = post
        score.save
      end
    end
  end
  
  def self.rescore_section(section)
    scores = section.scores
    scores.each do |score|
      post = Assessing.score_assessment(section.published, score.scoring)
      score.scoring = post
      score.save
    end
  end
  
end