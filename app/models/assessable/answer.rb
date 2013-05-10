module Assessable
  class Answer < ActiveRecord::Base
    belongs_to :question, :touch => true
    attr_accessible :answer_text, :key, :other_question, :question_id, :requires_other, :sequence, :short_name, :text_eval, :value
    
    validates_numericality_of :value, :greater_than_or_equal_to => 0
   
    
    
  end
end
