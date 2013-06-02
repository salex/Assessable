require 'test_helper'

def new_session
 return {"_csrf_token"=>"cF7uZe4k0fxooMvTJsim9uphGBpIvQC6Wbpz3ZXAq1U=", "session_id"=>"f2e41b5201b61cfc0f2517b6d6889cd3", "user_id"=>4}
end

def published
  return {"assessing_key"=>"", "category"=>"case.test", "default_layout"=>"", "default_tag"=>"", 
    "description"=>"two 3 answer yes no maybe questions to provide test published ", "id"=>12, "instructions"=>"", 
    "key"=>"", "max_raw"=>6.0, "max_weighted"=>6.0, "name"=>"test case", "status"=>"New", 
    "questions"=>[{"answer_layout"=>"List", "answer_tag"=>"Radio", "assessment_id"=>12, "critical"=>true, "group_header"=>"", "id"=>47, 
    "instructions"=>"", "key"=>"", "min_critical"=>1.0, "question_text"=>"one", "score_method"=>"Value", "sequence"=>1, 
    "short_name"=>"on", "weight"=>1.0, "answers"=>[{"answer_text"=>"no", "id"=>205, "key"=>nil, "other_question"=>"", "question_id"=>47, 
    "requires_other"=>false, "sequence"=>1, "short_name"=>"", "text_eval"=>nil, "value"=>0.0}, {"answer_text"=>"maybe", "id"=>206, "key"=>nil, 
    "other_question"=>"why so decisive?", "question_id"=>47, "requires_other"=>true, "sequence"=>2, "short_name"=>"", 
    "text_eval"=>nil, "value"=>1.0}, {"answer_text"=>"yes", "id"=>207, "key"=>nil, "other_question"=>"", "question_id"=>47, "requires_other"=>false, 
    "sequence"=>3, "short_name"=>"", "text_eval"=>nil, "value"=>2.0}]}, {"answer_layout"=>"List", "answer_tag"=>"Radio", 
    "assessment_id"=>12, "critical"=>false, "group_header"=>"", "id"=>48, "instructions"=>"", "key"=>"", "min_critical"=>nil, 
    "question_text"=>"two", "score_method"=>"Value", "sequence"=>2, "short_name"=>"two", "weight"=>1.0, 
    "answers"=>[{"answer_text"=>"no", "id"=>208, "key"=>nil, "other_question"=>"", "question_id"=>48, "requires_other"=>false, "sequence"=>1, 
    "short_name"=>"", "text_eval"=>nil, "value"=>0.0}, {"answer_text"=>"maybe", "id"=>209, "key"=>nil, "other_question"=>"why so decisive?", 
    "question_id"=>48, "requires_other"=>true, "sequence"=>2, "short_name"=>"", "text_eval"=>nil, "value"=>1.0}, {"answer_text"=>"yes", 
    "id"=>210, "key"=>nil, "other_question"=>"", "question_id"=>48, "requires_other"=>false, "sequence"=>3, "short_name"=>"", "text_eval"=>nil, 
    "value"=>2.0}]}, {"answer_layout"=>"List", "answer_tag"=>"Text", "assessment_id"=>12, "critical"=>false, "group_header"=>"", "id"=>49, 
    "instructions"=>"please enter one or two", "key"=>"", "min_critical"=>nil, "question_text"=>"Which is better, one or two", 
    "score_method"=>"TextContains", "sequence"=>3, "short_name"=>"", "weight"=>1.0, "answers"=>[{"answer_text"=>"Choose Me!", "id"=>211, 
    "key"=>nil, "other_question"=>"", "question_id"=>49, "requires_other"=>false, "sequence"=>1, "short_name"=>"", 
    "text_eval"=>"one&!two||two&!one", "value"=>2.0}]}]}
end

describe Take do
  let(:employee_user) {User.create(username: 'Joe Employee', role: 'Employee')}
  let(:citizen_user) {User.create(username: 'Joe Citizen', role: 'Citizen')}
  def setup
    @assessor = Assessor.create(:assessoring_type => 'Stage', assessoring_id:1, assessed_model: 'User', status: 'active', before_method: 'Assessor.can_take')
    section = @assessor.assessor_sections.create(:assessment_id => 1, status: 'active', sequence: 1, category: 'general', published: published)
    section = @assessor.assessor_sections.create(:assessment_id => 2, status: 'active', sequence: 2, category: 'education.model', published: published)
    
  end
  
  describe "let tests" do
    it "citizen role is citizen" do
      citizen_user.role.must_equal 'Citizen'
    end
    it "employee role is employee" do
      employee_user.role.must_equal 'Employee'
    end
    
  end

  describe "initialize new" do
    #@user_session = {"_csrf_token"=>"cF7uZe4k0fxooMvTJsim9uphGBpIvQC6Wbpz3ZXAq1U=", "session_id"=>"f2e41b5201b61cfc0f2517b6d6889cd3", "user_id"=>4}
    
    init = Take.new(new_session,true)
    it "should have a stash" do
      init.stash.wont_be_nil
    end
    it "should have nil data" do
      init.stash.data.must_be_nil
    end
    
    it "stash session should have user_id key" do
      assert init.stash.session.has_key?('user_id'), "keyis #{init.stash.inspect}"
    end
  end

  describe "initialize saved no clear" do

    init = Take.new(new_session)
    it "should have a stash" do
      init.stash.wont_be_nil
    end
    
    it "stash session should have user_id key" do
      assert init.stash.session.has_key?('user_id'), "keyis #{init.stash.inspect}"
    end
    it "stash session user id should be 4" do
      assert init.stash.session['user_id'].must_equal 4 
    end
    
  end

  describe "create new assessor and sections" do
    it "show have stuff" do
      
      @assessor.assessoring_type.must_equal 'Stage'
    end
    it "should have two sections" do
      @assessor.assessor_sections.count.must_equal 2
    end
  end
  
  describe "get taking stuff" do
    before do
      @taking = Take.new(new_session).apply_setup(@assessor,citizen_user)
      @section = @taking.get_section
    end
    it "should be a hash" do
      #taking = Take.new(new_session).apply_setup(@assessor,citizen_user).taking
      @taking.taking.class.must_equal Hash
    end
    it "should have assessed_type as User" do
      @taking.taking['assessed_type'].must_equal 'User'
    end
    it "Should have a nil post" do
      @post = @section.get_section.post
      @post.must_be_nil
    end
    it "should have published" do
      @published = @section.section.published
      @published.wont_be_nil
    end
    it "taking idx should be 0" do
      @section.taking['idx'].must_equal 0
    end
    
  end
  
    
  
end
