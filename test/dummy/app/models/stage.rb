class Stage < ActiveRecord::Base
  attr_accessible :name
  has_many :assessors, as: :assessoring, :dependent => :destroy
  has_many :assessor_sections, :through => :assessors
  has_many :scores, :through => :assessor_sections
  # def scores
  #   assessors = self.assessors
  #   sections = []
  #   assessors.each do |assessor|
  #     sections += assessor.assessor_sections.pluck(:id)
  #   end
  #   return Score.where(:assessor_section_id => sections)
  # end
end
