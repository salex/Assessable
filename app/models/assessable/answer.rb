module Assessable
  class Answer < ActiveRecord::Base
    belongs_to :question
    attr_accessible :answer_text, :key, :other_question, :question_id, :requires_other, :sequence, :short_name, :text_eval, :value
    
    after_save :updateMax
    after_destroy :updateMax
    validates_numericality_of :value, :greater_than_or_equal_to => 0
    
    private

    def updateMax
      if self.question
        Assessment.computeMax(self.question.assessment.id) if is_dirty?
      end
    end

    def is_dirty?
       dirty = false
       self.changed.each{|attrib|
         dirty =  (dirty || !( /value|answer_eval/i =~ attrib ).nil?)
       }
       logger.debug "DDDDDDDDDDDDDDDD #{dirty}"
      return dirty
    end
    
  end
end
