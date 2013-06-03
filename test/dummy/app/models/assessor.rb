class Assessor < ActiveRecord::Base
  attr_accessible :assessed_model, :assessoring_id, :assessoring_type, :instructions, :before_method, :after_method, :repeating, :sectionable, :name, :status
  belongs_to :assessoring, :polymorphic => true
  has_many :assessor_sections, :order => "sequence", :dependent => :destroy
  
  TypeAssessors = %w(take score evaluate survey)
  
  def assessment_search(params)
    assessments = Assessable::Assessment.search(params)
    sections = self.assessor_sections.pluck(:assessment_id).uniq
    assessments = assessments.where("id not in (?)",sections) unless sections.empty?
    return assessments
  end
  
  
end
# Assessor spec
#   Type Assessors
#     Take - logged in user takes assessment
#     Score - logged in user scores(takes) assessment for another user
#     Evaluate - same as score
#     Survey - guest or user takes assessment, scores summed in one score
#   
#   Repeating - old scores not used (annual evaluations, test)
#   Sectionable- each section can be taken alone, complete with all seections take (false all seections taken at one time with multiple pages)
#   Status active, archived, abandoned
#   before method - ability
#   after method - rollup
# 
# 
# Section spec
#   Status active, archived, abandoned
#   model method - method creates post
#   
#   
  