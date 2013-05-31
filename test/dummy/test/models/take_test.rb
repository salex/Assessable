require 'test_helper'

describe Take do
  before do
    @assessor = Assessor.create(:assessoring_type => 'Stage', assessoring_id:1, assessed_model: 'User', status: 'active', before_method: 'Assessor.can_take')
    section = @assessor.assessor_sections.build(:assessment_id => 1, status: 'active', sequence: 1, category: 'general')
    section.save
    section = @assessor.assessor_sections.build(:assessment_id => 2, status: 'active', sequence: 2, category: 'education.model')
    section.save
    
  end

  describe "initialize new" do
    @session = {"_csrf_token"=>"cF7uZe4k0fxooMvTJsim9uphGBpIvQC6Wbpz3ZXAq1U=", "session_id"=>"f2e41b5201b61cfc0f2517b6d6889cd3", "user_id"=>4}
    

    init = Take.new(@session,true)
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
    @session = {"_csrf_token"=>"cF7uZe4k0fxooMvTJsim9uphGBpIvQC6Wbpz3ZXAq1U=", "session_id"=>"f2e41b5201b61cfc0f2517b6d6889cd3", "user_id"=>4}

    init = Take.new(@session)
    it "should have a stash" do
      init.stash.wont_be_nil
    end
    
    it "stash session should have user_id key" do
      assert init.stash.session.has_key?('user_id'), "keyis #{init.stash.inspect}"
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
  
end
