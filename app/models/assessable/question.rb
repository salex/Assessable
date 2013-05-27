module Assessable
  class Question < ActiveRecord::Base
    belongs_to :assessment, :touch => true
    has_many :answers, :order => "sequence", :dependent => :destroy
    before_save :valid_score_method
    validates_numericality_of :min_critical,  :greater_than_or_equal_to => 0, :if => :critical, :message => "must be a number if critical checkbox checked"
    validates_numericality_of :weight, :greater_than_or_equal_to => 0
    validates_presence_of :assessment_id, :answer_tag, :score_method
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
    

    def valid_score_method?
      return false if self.score_method.nil? || self.answer_tag.nil?
      if score_as_multi?
        unless valid_scoring_for_multi?
          self.errors.add :score_method, "Score Method must be None, Sum or Max for Checkbox or Select-multiple tags"
          return false
        end
      elsif score_as_text?
        unless valid_scoring_for_text?
          self.errors.add :score_method, "Score Method must be None, TextCompletion or TextNumeric for Text or Textarea tags"
          return false
        end
      else
        unless valid_scoring_for_generic?
          self.errors.add :score_method, "Score Method #{score_method} invalid for tag #{answer_tag}"
          return false
        end
      end
      true
    end

    private

    def score_as_multi?
      answer_type_in?(['checkbox', 'select-multiple'])
    end

    def score_as_text?
      answer_type_in?(['text', 'textarea'])
    end

    def answer_type_in?(valid_types)
      valid_types.include?(self.answer_tag.downcase)
    end

    def valid_scoring_for_multi?
      score_method_in?(['sum', 'max', 'none'])
    end

    def valid_scoring_for_text?
      score_method_in?(['textcontains', 'textnumeric', 'none'])
    end

    def valid_scoring_for_generic?
      score_method_in?(['value', 'none'])
    end

    def score_method_in?(valid_score_methods)
      valid_score_methods.include?(self.score_method.downcase)
    end

  end
end
