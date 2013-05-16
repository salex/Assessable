class Assessor < ActiveRecord::Base
  attr_accessible :assessed_model, :assessoring_id, :assessoring_type, :instructions, :method, :name, :status
  belongs_to :assessoring, :polymorphic => true
  has_many :assessor_sections, :order => "sequence", :dependent => :destroy
  
  def assessment_search(params)
    assessments = Assessable::Assessment.search(params)
    sections = self.assessor_sections.pluck(:assessment_id).uniq
    assessments = assessments.where("id not in (?)",sections) unless sections.empty?
    
    # params[:where] = "Contains" unless params[:where]
    # params[:key] = self.assessoring_type unless params[:key]
    # params[:status] = "" unless params[:status]
    # case params[:where]
    # when 'Start with'
    #  key =  params[:key] + "%"
    # when 'Contains'
    #  key = "%" + params[:key] + "%"
    # when "Ends with"
    #  key = "%" + params[:key]
    # else
    #  key = params[:key]
    # end
    # # For psql, change LIKE to ILIKE or downcase everything
    # ilike =  "category LIKE '#{key}' OR assessing_key LIKE '#{key}' OR name LIKE '#{key}' OR description LIKE '#{key}'"
    # assessments = assessments.where(ilike)
    return assessments
  end
  
end
