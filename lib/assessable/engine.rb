module Assessable
  class Engine < ::Rails::Engine
    isolate_namespace Assessable
    
    config.generators do |g|
      g.orm             :active_record
      g.template_engine :haml
      g.test_framework  :mini_test
    end
    
    
  end
end
