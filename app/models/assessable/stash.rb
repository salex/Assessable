module Assessable
  ## Stash is a version of Session Store .
  # Two columns, :session and :data allow storage of data using JSON serialization
  # :session can be used as required, in this case, limited information on the assessment(s)
  # being entered are stored.
  # :data is another gentic data store, in this case, post data from single or multiple forms/assessments are stored
  
  class Stash < ActiveRecord::Base
    serialize :session, JSON
    serialize :data, JSON
    
    ## Get or create as Stash instance by session_id
    def self.get(session)
      Stash.sweep
      #self.find_or_create_by_session_id(session["session_id"])
      self.find_or_create_by(session_id: session["session_id"])
    end
    
    ## Destroy the Stash session
    def self.clear(session)
      this_session = self.find_by_session_id(session["session_id"])
      if this_session
        this_session.destroy
      end
    end
    
    ## Clears all outdated Stash Sessions
    def self.sweep(time = 2)
      self.delete_all "updated_at < '#{time.hours.ago}' OR created_at < '#{2.days.ago}'"
    end
    
    ## looks for a post hash inside the data serialized hash by id
    # returns the hash or nil
    def get_post(id)
      hash = self.get_data
      result = nil
      if hash && hash.has_key?("post")
        result = hash["post"][id.to_s]
      end
      return result
    end
    
    def self.get_post(id, session)
      stash = Stash.get(session)
      @post = stash.get_post(id) 
    end
    
    def self.set_post(id,post,session)
      stash = Stash.get(session)
      stash.set_post(id,post)
    end
    
    ## sets a post by a user defined id inside the data serailsized hash
    # if post hash is not found, it creates it
    # updates or creates post['id'] hash
    def set_post(id,post)
      hash = self.get_data
      hash = hash.nil? ? {} : hash
      hash["post"] = {} unless hash["post"]
      hash["post"][id.to_s] = post
      self.data = hash      
      self.save
      return self
    end
    
    ## not really needed,  just an alise on self.data, but does return nil if contains and empty hash
    def get_data
      result =  self.data  # returns empty has if no json or error
      return result.nil? || result.empty? ? nil : result 
    end
    
  end
end
