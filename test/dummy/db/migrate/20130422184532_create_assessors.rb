class CreateAssessors < ActiveRecord::Migration
  def change
    create_table :assessors do |t|
      t.string :assessing_type
      t.integer :assessing_id
      t.string :assessed_model
      t.string :name
      t.string :status
      t.string :instructions
      t.string :method

      t.timestamps
    end
  end
end
