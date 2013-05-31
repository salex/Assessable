module TakeHelper
  def new_assessor(type)
    assessor = Assessor.create(:assessoring_type => 'Stage', assessoring_id:1, assessed_model: 'User', status: 'active', method: 'Assessor.can_take')
    new_section(assessor)
    return assessor
  end
  
  def new_section(assessor)
    section = assessor.assessor_sections.build(:assessment_id => 1, status: 'active', sequence: 1, category: 'general')
    section.save
    section = assessor.assessor_sections.build(:assessment_id => 2, status: 'active', sequence: 2, category: 'education.model')
    section.save
  end
end