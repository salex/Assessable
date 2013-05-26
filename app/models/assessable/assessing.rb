module Assessable
    
  class Assessing
    # This generic class provides a number of class methods that interface with Assessable without using namespacing.
    #   The modules/models it interfaces with are:
    #     Displaying module
    #       Display class
    #     Scoring module
    #       Score class
    #     Stash class
      
    ## Stash
    def self.get_post(id, session)
      # Equivilalant to Assessable::Stash.get(session).get_pos(id)
      # retrieves a post stored in a stash by a user defined id and session_id
      stash = Stash.get(session)
      post = stash.get_post(id) 
    end
    
    def self.set_post(id,post,session)
      # Equivilalant to Assessable::Stash.get(session).set_post(id,post)
      # Stores a post in a stash by a user defined id and session_id
      stash = Stash.get(session)
      stash.set_post(id,post)
    end
    
    def self.get_stash(session)
      # gets or creates a Stash instance by session_id
      stash = Stash.get(session)
    end
    
    def self.clear_stash(session)
      #clears (destroys) as stash instance by session id
      Stash.clear(session)
    end
    
    ## Scoring Module
    def self.score_assessment(published_assessment,post)
      # returns a scoring object
      scoring = Assessable::Scoring::Score.new(published_assessment,post)
      # The basic instantiation returns the object that has three attr_reader properties and on instance method
      #   scoring.post returns the original post
      #   scoring.all_answers returns an array of all answer ids as string. (@post["answer"].values.flatten)
      #   scoring.scores returns a scoring hash that contains raw and weighted scores for each question/answer(s) as well as total and percentage scores
      #   scoring.scored_post, appends the scores hash to the original post
    end
    
    def self.display_assessment(published_assessment,post=nil)
      # renders html for the published_assessment object
      # the post argument is optional and ignores the scores object if includes.
      # calls a class method in the Assessable::Displaying::Display class
      # that creates a display object and returns just the html.
      Assessable::Displaying::Display.assessment(published_assessment,post)
    end
    
  end
  
end

