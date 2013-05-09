module Assessable
  class Question < ActiveRecord::Base
    belongs_to :assessment
    has_many :answers, :order => "sequence", :dependent => :destroy
    before_save :valid_score_method
    after_save :updateMax
    after_destroy :updateMax
    validates_numericality_of :min_critical, :if => :critical, :message => "must be a number if critical checkbox checked"
    validates_numericality_of :weight, :greater_than_or_equal_to => 0
    accepts_nested_attributes_for :answers, :reject_if => lambda { |a| a[:answer_text].blank? }, :allow_destroy => true
    
    attr_accessible :answer_layout, :answer_tag, :critical, :group_header, :instructions, :key, :min_critical, :question_text, :score_method, :sequence, :short_name, :assessment_id, :weight, :answers_attributes


    def clone
      max = self.assessment.questions.maximum(:sequence) 
      new_sequence = max.nil? ? 1  : max + 1
      
      answers = self.answers
      new_ques = self.dup
      new_ques.assessment_id = self.assessment_id
      new_ques.question_text = "Cloned #{new_ques.question_text}"
      new_ques.sequence = new_sequence
      new_ques.save
      new_quesid = new_ques.id
      for answer in answers
        new_ans = answer.dup
        new_ans.question_id = new_quesid
        new_ans.save
      end
      return new_ques
    end


    private

    def set_defaults
      if ((self.score_method.downcase == "sum") || (self.score_method.downcase == "max")) && ((self.answer_tag.downcase == "checkbox") || (self.answer_tag.downcase == "select-multiple") )
        self.score_method = self.score_method.capitalize
      else
        self.score_method = "Value" unless self.score_method.downcase == "none"
      end
    end

    def updateMax
      if self.assessment
        Assessment.computeMax(self.assessment.id) if is_dirty?
      end
    end
    
    def valid_score_method
      if ((self.answer_tag.downcase == "checkbox") || (self.answer_tag.downcase == "select-multiple") )
        unless ((self.score_method.downcase == "sum") || (self.score_method.downcase == "max")  || (self.score_method.downcase == "none")) 
          self.errors[:base] << "Score Method must be None, Sum or Max for Checkbox or Select-multiple tags"
          return false
        end
      elsif ((self.answer_tag.downcase == "text") || (self.answer_tag.downcase == "textarea") )
        unless ((self.score_method.downcase == "textcontains") || (self.score_method.downcase == "textnumeric")  || (self.score_method.downcase == "none")) 
          self.errors[:base] << "Score Method must be None, TextCompletion or TextNumeric for Text or Textarea tags"
          return false
        end
      else
        unless ((self.score_method.downcase == "value") || (self.score_method.downcase == "none")) 
          self.errors[:base] << "Score Method #{self.score_method} invalid for tag #{self.answer_tag}"
          return false
        end
      end
    end

    def is_dirty?
       dirty = false
       self.changed.each{|attrib|
         dirty =  (dirty || !( /score_method|weight|critical|minimum_value/i =~ attrib ).nil?)
       }
      return dirty
    end
    
    

  end
end
