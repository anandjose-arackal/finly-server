class AddExceptionToLrm < ActiveRecord::Migration[5.2]
  def change
    # LRM
    add_column :level_reviewer_mappings, :wo_exception, :boolean, default: true

    # DLRM
    add_column :document_level_reviewer_mappings, :wo_exception, :boolean, default: true

    # LURM
    add_column :level_user_reviewer_mappings, :wo_exception, :boolean, default: true
  end
end
