class CreateAssessableStashes < ActiveRecord::Migration
  def change
    create_table :assessable_stashes do |t|
      t.string :session_id
      t.text :session
      t.text :data

      t.timestamps
    end
  end
end
