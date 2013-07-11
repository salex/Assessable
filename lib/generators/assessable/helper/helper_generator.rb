module Assessable
  module Generators
    class HelperGenerator < Rails::Generators::Base
      desc "This generator creates full helper"
      source_root File.expand_path('../templates', __FILE__)
      def create_helper_file
        copy_file "display_helper.rb", "app/helpers/assessable/display_helper.rb"
      end
      
    end
  end
end