class CreateAssessableQuestions < ActiveRecord::Migration
  def change
    create_table :assessable_questions do |t|
      t.integer :assessment_id
      t.integer :sequence
      t.string :question_text
      t.string :short_name
      t.string :instructions
      t.string :group_header
      t.string :answer_tag
      t.string :answer_layout
      t.float :weight, :default => 1.0
      t.boolean :critical, :defalt => false
      t.float :min_critical
      t.string :score_method
      t.string :key

      t.timestamps
    end
  end
end
