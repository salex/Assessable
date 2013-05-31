class AddColumnToAssessor < ActiveRecord::Migration
  def change
    add_column :assessors, :sectionable, :boolean
    add_column :assessors, :repeating, :boolean
    add_column :assessors, :after_method, :string
    rename_column :assessors, :method, :before_method
    add_column :assessor_sections, :model_method, :string
  end
end
