require 'test_helper'

describe Assessable::Question do
  describe "validations" do
    question = Assessable::Question.new 
  
    it "requires question_id" do
      refute question.valid?
      question.assessment_id = 1
    end
    it "requires answer tag" do
      refute question.valid?
      question.answer_tag = "shit"
    end
    it "requires score_method" do
      refute question.valid?
      question.score_method = 'crap'
    end
    it "requires matched pairs shit and crap wont match" do
      assert question.valid?
      refute question.valid_score_method?, "crap and shit are not valid"
    end
    it "should match pairs text and none" do
      question.score_method = 'none'
      question.answer_tag = "text"
      assert question.valid_score_method?, "text and none valid"
    end
    
    it "score_method none should match all" do
      %w(radio checkbox select select_multiple text textarea).each do |t|
        question.answer_tag = t
        assert question.valid_score_method?, "#{question.score_method} and #{question.answer_tag}"
      end
      
    end
    it "requires min_critical if critical" do
      question.critical = true
      refute question.valid?
    end
    it "fail if min_critical < 0" do
      question.min_critical = -1
      refute question.valid?
    end
    it "pass if min_critical >= 0" do
      question.min_critical = 0
      assert question.valid?
    end
  
  end
  
end

