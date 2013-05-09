class CreateAssessorSections < ActiveRecord::Migration
  def change
    create_table :assessor_sections do |t|
      t.integer :assessor_id
      t.integer :assessment_id
      t.integer :sequence
      t.string :name
      t.string :status
      t.string :instructions
      t.string :category
      t.float :max
      t.float :weighted
      t.text :published
      t.datetime :published_at

      t.timestamps
    end
  end
end
