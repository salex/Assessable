require "assessable/engine"
require "assessable/text_eval"

module Assessable
  
  def self.safe_json_decode( json )
    return {} if !json
    begin
      ActiveSupport::JSON.decode json
    rescue ; {} end
  end
  
   mattr_accessor :config
   @@config = {} 
   @@config[:assessment_status_options] =  %w(New Published Archived)
end
