# require 'test_helper'
# 
# describe Assessable::Scoring do
#   before do
#     @assessment =  {"id"=>1, "max_raw"=>4.0, "max_weighted"=>4.0, 
#       "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"Value", "weight"=>1.0, 
#         "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}, 
#         {"critical"=>false, "id"=>2, "min_critical"=>nil, "score_method"=>"Value", "weight"=>1.0, 
#           "answers"=>[{"id"=>11, "text_eval"=>nil, "value"=>0.0}, {"id"=>12, "text_eval"=>nil, "value"=>1.0}, {"id"=>13, "text_eval"=>nil, "value"=>2.0}]}]}
#     @post = {"answer"=>{"1"=>["1"], "2"=>["12"]}}
#     @score = nil
#   end
# 
#   describe "basic assessment setup" do
#     it "must be instance of hash" do
#       @assessment.must_be_instance_of Hash
#     end
#     
#     it "questions be instance of array" do
#       @assessment["questions"].must_be_instance_of Array
#     end
#     
#     
#   end
# 
  # describe "basic post setup" do
  #   it "must be hash" do
  #     @post.must_be_instance_of Hash
  #   end
  #   
  #    it "answer" do
  #      @post["answer"].wont_be_nil
  #    end
  # end
  # 
  # describe "score creates new object" do
  #   it "must be a score object" do
  #     @score = Assessable::Scoring::Score.new(@assessment,@post)
  #     @score.must_be_instance_of Assessable::Scoring::Score
  #     @score.total_raw.must_equal 0
  #     @score.scores["max"]["raw"].must_equal @assessment["max_raw"]
  #   end
  # end
  # 
  # describe "does @score have something" do
  #   it "must be a score object" do
  #     @assessment["max_raw"] = 10.0
  #     @score = Assessable::Scoring::Score.new(@assessment,@post)
  #     @score.scores["max"]["raw"].must_equal 10.0
  #     @score.must_be_instance_of Assessable::Scoring::Score
  #   end
  # end
  
#end
