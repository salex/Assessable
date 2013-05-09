class RenameAssessingIdInAssessor < ActiveRecord::Migration
  def change
    rename_column :assessors, :assessing_id, :assessoring_id
    rename_column :assessors, :assessing_type, :assessoring_type
  end

end
