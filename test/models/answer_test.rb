require 'test_helper'

describe Assessable::Answer do
  describe "validations" do
    answer = Assessable::Answer.new 
  
    it "requires question_id" do
      refute answer.valid?
      answer.question_id = 1
    end
  
  
    it "requires value >= 0" do
      refute answer.valid?
      answer.value = 0
      assert answer.valid?
    end
  end
end
