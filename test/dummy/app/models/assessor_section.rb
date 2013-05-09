class AssessorSection < ActiveRecord::Base
  attr_accessible :assessment_id, :assessor_id, :category, :instructions, :max, :name, :published, :published_at, :sequence, :status, :weighted
  belongs_to :assessor
  has_many :scores, :dependent => :destroy
  
  serialize :published, JSON
  
  def assessment
    return nil if self.assessment_id.nil?
    Assessable::Assessment.find(self.assessment_id)
  end
  
  def get_published
    assessment = self.assessment
    return nil if assessment.nil?
    # assessment.key = "#{self.class.name}.#{self.stage.class.name}.#{self.stage_id}.#{self.category}"
    #assessment.save
    self.published = assessment.publish
    self.max = assessment["max_raw"]
    self.weighted = assessment["max_weighted"]
    self.published_at = assessment["updated_at"]
  end
  
  def assessment_stale?
    self.assessment.updated_at != self.published_at
  end
  
  # def publish_or_clone(params)
  #   if params[:stale]
  #     if params[:stale] == "publish"
  #       self.get_published 
  #       return self
  #     end
  #     if params[:stale] == "clone"
  #       old = self
  #       clone = old.dup
  #       clone.name = "Cloned #{clone.name}"
  #       clone.get_published
  #       old.status = old.status.gsub("active","archived")
  #       old.save
  #       return clone
  #     end
  #   end
  # end
end

