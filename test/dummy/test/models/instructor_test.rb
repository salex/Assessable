require "test_helper"

describe Instructor do
  before do
    @instructor = Instructor.new
  end

  it "must be valid" do
    @instructor.valid?.must_equal true
  end
end
