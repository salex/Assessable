class AddIndexes < ActiveRecord::Migration
  def up
    add_index :assessable_questions, :assessment_id
    add_index :assessable_answers, :question_id
    add_index :assessable_assessments, :assessing_key
    add_index :assessable_stashes, :session_id
  end

  def down
    remove_index :assessable_questions, :assessment_id
    remove_index :assessable_answers, :question_id
    remove_index :assessable_assessments, :assessing_key
    remove_index :assessable_stashes, :session_id
  end
end
