require 'test_helper'

describe Assessable::Scoring do
  before do
    @assessment =  {"id"=>1, "max_raw"=>4.0, "max_weighted"=>4.0, 
      "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"Value", "weight"=>1.0, 
        "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}, 
        {"critical"=>false, "id"=>2, "min_critical"=>nil, "score_method"=>"Value", "weight"=>1.0, 
          "answers"=>[{"id"=>11, "text_eval"=>nil, "value"=>0.0}, {"id"=>12, "text_eval"=>nil, "value"=>1.0}, {"id"=>13, "text_eval"=>nil, "value"=>2.0}]}]}
    @post = {"answer"=>{"1"=>["1"], "2"=>["13"]}}
    @score = nil
  end

  
  describe "score creates new object" do
    it "must be a score object" do
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.must_be_instance_of Assessable::Scoring::Score
      @score.scores["total"]["raw"].must_equal 2
      @score.scores["max"]["raw"].must_equal @assessment["max_raw"]
    end
  end
  
  describe "can modify the before assessment" do
    it "max must be different after modify" do
      @assessment["max_raw"] = 10.0
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["max"]["raw"].must_equal 10.0
      @score.must_be_instance_of Assessable::Scoring::Score
    end
  end
        
  describe "critical failure" do
    
    it "should have a critical failure" do
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["critical"].wont_be_nil
    end
    it "should say question 1 failed critical test" do
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["critical"][0].must_equal "1"
    end
    
    it "should not fail critical" do
      @assessment =  {"id"=>1, "max_raw"=>4.0, "max_weighted"=>4.0, 
        "questions"=>[{"critical"=>false, "id"=>1, "min_critical"=>1.0, "score_method"=>"Value", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["critical"].must_be_nil
    end
  end
  
  describe "Sum scoring" do
    it "should sum to 3 if all checked" do
      @assessment =  {"id"=>1, "max_raw"=>3.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"Sum", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["1","2","3"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 3.0
      @score.scores["percent"]["raw"].must_equal 1.0
    end
    it "should sum to 3 if 2 & 3 checked" do
      @assessment =  {"id"=>1, "max_raw"=>3.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"Sum", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["2","3"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 3.0
    end
    
    it "should sum to 0 if 1 checked" do
      @assessment =  {"id"=>1, "max_raw"=>3.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"Sum", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.0
    end
    it "should sum to 1 if 2 checked" do
      @assessment =  {"id"=>1, "max_raw"=>3.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"Sum", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["2"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 1.0
      @score.scores["percent"]["raw"].must_equal 0.333
      
    end
    it "should sum to 2 if 3 checked" do
      @assessment =  {"id"=>1, "max_raw"=>3.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"Sum", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["3"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 2.0
    end    
  end
      
  describe "max scoring" do
    it "should sum to 2 if all checked" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"max", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["1","2","3"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 2.0
    end
    it "should sum to 0 if 1 checked" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"max", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.0
    end
    it "should sum to 1 if 2 checked" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"max", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["2"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 1.0
    end
    it "should sum to 2 if 3 checked" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"max", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["3"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 2.0
    end    
  end
  
  describe "value scoring" do
    it "should sum to 0 if 1 checked" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"value", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.0
    end
    it "should sum to 1 if 2 checked" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"value", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["2"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 1.0
      @score.scores["percent"]["raw"].must_be_close_to 0.50009
      assert_in_delta 0.5, @score.scores["percent"]["raw"], 0.001, "close enough"
      
    end
    it "should sum to 2 if 3 checked" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"value", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["3"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 2.0
    end    
  end
  
  describe "none scoring" do
    it "should sum to 0 if anything checked" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"none", "weight"=>1.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["1","2","3"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.0
    end
  end
  
  describe "Weighted value score" do
    it "should sum to 6 if anything checked" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>6.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"value", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}]}
      @post = {"answer"=>{"1"=>["3"]}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 2.0
      @score.scores["total"]["weighted"].must_equal 6.0
    end
  end
  
  describe "text contains scoring" do
    it "should match one" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>6.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textcontains", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"one", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"one"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 1.0
    end
    it "should not match two" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>6.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textcontains", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"one", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"two"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.0
    end
    it "should not or two" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>6.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textcontains", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"(one|two)", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"two"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 1.0
    end
    it "should not match one&two" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>6.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textcontains", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"one&two", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"two"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.0
    end
    it "should match one&two" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>6.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textcontains", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"one&two", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"two one"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 1.0
    end
    it "should match partial two" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>6.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textcontains", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"one&two::two%%50.0", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"two "}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.5
    end
    it "should match one&two but not three" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>6.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textcontains", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"one&two&!three", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"two one three"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.0
    end
    it "should match one&two but 50% partial three" do
      @assessment =  {"id"=>1, "max_raw"=>2.0, "max_weighted"=>6.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textcontains", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"one&two&!three::one&two&three%%50.0", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"two one three"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.5
    end
  end
  
  describe "text numeric scoring" do
    it "should match 3.1416" do
      @assessment =  {"id"=>1, "max_raw"=>1.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textnumeric", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"3.1416", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"3.1416"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 1.0
    end
    it "should not match 3.14159" do
      @assessment =  {"id"=>1, "max_raw"=>1.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textnumeric", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"3.1416", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"3.14159"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.0
    end
    it "should match 3.14159 with delta" do
      @assessment =  {"id"=>1, "max_raw"=>1.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textnumeric", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"3.1416::0.00001%%100.0", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"3.14159"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 1.0
    end
    
    it "should match 3.14159 with delta 50% partial" do
      @assessment =  {"id"=>1, "max_raw"=>1.0, "max_weighted"=>3.0, 
        "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"textnumeric", "weight"=>3.0, 
          "answers"=>[{"id"=>1, "text_eval"=>"3.1416::0.00001%%50.0", "value"=>1.0}]}]}
      @post = {"answer"=>{"1"=>["1"]}, "text"=> {"1" =>"3.14159"}}
      @score = Assessable::Scoring::Score.new(@assessment,@post)
      @score.scores["total"]["raw"].must_equal 0.5
    end
    
  end
  
end
