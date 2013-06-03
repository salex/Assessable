require "test_helper"

describe ModelAssessor do
  before do
    @model_assessor = ModelAssessor.new
  end

  it "must be valid" do
    @model_assessor.valid?.must_equal true
  end
end
