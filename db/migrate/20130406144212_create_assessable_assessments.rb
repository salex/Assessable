class CreateAssessableAssessments < ActiveRecord::Migration
  def change
    create_table :assessable_assessments do |t|
      t.string :name
      t.string :category
      t.string :description
      t.string :instructions
      t.string :key
      t.string :default_tag
      t.string :default_layout
      t.float :max_raw
      t.float :max_weighted
      t.string :status

      t.timestamps
    end
  end
end
