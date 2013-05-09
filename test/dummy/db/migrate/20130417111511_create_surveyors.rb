class CreateSurveyors < ActiveRecord::Migration
  def change
    create_table :surveyors do |t|
      t.integer :assessment_id
      t.integer :sequence
      t.string :assessable_type
      t.integer :assessable_id
      t.text :published_assessment
      t.datetime :version_at
      t.string :name
      t.string :category
      t.text :instructions

      t.timestamps
    end
  end
end
