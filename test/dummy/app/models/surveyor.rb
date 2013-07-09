class Surveyor < ActiveRecord::Base
  #attr_accessible :category, :instructions, :name, :published_assessment, :sequence, :assessment_id, :assessable_id, :assessable_type, :version_at
  serialize :published_assessment, JSON
  
  def assessment
    return nil if self.assessment_id.nil?
    Assessable::Assessment.find(self.assessment_id)
  end
  
  def get_published
    assessment = self.assessment
    return nil if assessment.nil?
    # assessment.key = "#{self.class.name}.#{self.stage.class.name}.#{self.stage_id}.#{self.category}"
    # assessment.save
    self.published_assessment = assessment.publish
    # self.max_raw = assessment["max_raw"]
    # self.max_weighted = assessment["max_weighted"]
    # self.version = assessment["updated_at"]
  end
  
  def assessment_stale?
    self.assessment.updated_at != self.version_at
  end
  
  
  
end
