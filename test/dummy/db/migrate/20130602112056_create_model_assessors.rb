class CreateModelAssessors < ActiveRecord::Migration
  def change
    create_table :model_assessors do |t|
      t.string :name
      t.string :assessed_model

      t.timestamps
    end
  end
end
