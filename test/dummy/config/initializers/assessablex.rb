module Assessable
  self.config[:assessment_status_options] = %w(New Active Archived Published Dirty)
  self.config[:main_app_link_name] = 'Main Application'
end