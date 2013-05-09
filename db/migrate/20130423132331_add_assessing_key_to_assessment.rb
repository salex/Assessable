class AddAssessingKeyToAssessment < ActiveRecord::Migration
  def change
    add_column :assessable_assessments, :assessing_key, :string
  end
end
