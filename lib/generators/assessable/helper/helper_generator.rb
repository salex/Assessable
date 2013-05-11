module Assessable
  module Generators
    class HelperGenerator < Rails::Generators::Base
      desc "This generator creates full helper"
      source_root File.expand_path('../templates', __FILE__)
      def create_helper_file
        copy_file "take_helper.rb", "app/helpers/assessable/take_helper.rb"
      end
      
    end
  end
end