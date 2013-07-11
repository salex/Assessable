module Assessable
  # This helper copies the Assessable::DisplayHelper
  # and provides a two public method/functions 
    
    # def display_assessment(published,post=nil)
    #   which renders the assessment
    # 
    # def display_summary(published,post)
    #   which renders a version of a summary
    #   
  include Assessable::DisplayHelper
end
