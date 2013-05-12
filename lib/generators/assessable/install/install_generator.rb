module Assessable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "This generator creates an initializer file at config/initializers"
      source_root File.expand_path('../templates', __FILE__)
      def create_initializer_file
        copy_file "initializer.rb", "config/initializers/assessable.rb"
      end
      
      def create_assessing_file
        copy_file "assessing.rb", "app/models/assessing.rb"
      end
      
      def create_taking_file
        copy_file "take_helper.rb", "app/helpers/assessable/take_helper.rb"
      end
      
      def create_take_js_file
        #create_file "config/initializers/assessable.rb", "# Add initialization content here"
        copy_file "take.js.coffee", "app/assets/javascripts/assessable/take.js.coffee"
      end
      
      def create_take_scss_file
        #create_file "config/initializers/assessable.rb", "# Add initialization content here"
        copy_file "take.css.scss", "app/assets/stylesheets/assessable/take.css.scss"
      end
      
      def create_silly_file
        #create_file "config/initializers/assessable.rb", "# Add initialization content here"
        copy_file "silly.yaml", "db/assessable/silly.yaml"
      end
      
    end
  end
end