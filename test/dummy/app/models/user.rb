class User < ActiveRecord::Base
  attr_accessible :username, :role
  has_many :scores, as: :assessed
  
  def can_take(assessor)
    return true, "new"
  end
  def name
    self.username
  end
  
  def model_score(taking)
    scored_methods = []
    taking.stash.session["taking"]["models"].each do |as_id|
      section = AssessorSection.find(as_id)
      scored_methods << section.category
    end
    taking.stash.session["taking"]["scored_methods"] = scored_methods
    taking.stash.save
    return taking
  end
end
