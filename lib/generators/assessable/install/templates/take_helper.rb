module TakeHelper
  # This helper include the model Assessable::DisplayHelper
  # and provides a two public method/functions 
  # rails g Assessable:helper will replace this this file with one that includes the source code
  # if you wish to modify how an assessment or summary is displayed
    
    # def display_assessment(published,post=nil)
    #   which renders the assessment
    # 
    # def display_summary(published,post)
    #   which renders a version of a summary
    #   
  include Assessable::DisplayHelper
end
