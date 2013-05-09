class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :assessor_section_id
      t.string :assessed_type
      t.integer :assessed_id
      t.string :status
      t.float :raw
      t.float :weighted
      t.text :scoring
      t.string :answers
      t.string :category

      t.timestamps
    end
  end
end
