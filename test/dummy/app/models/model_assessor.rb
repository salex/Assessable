class ModelAssessor < ActiveRecord::Base
  #attr_accessible :assessed_model, :name
  has_many :assessors, as: :assessoring, :dependent => :destroy
  
end
