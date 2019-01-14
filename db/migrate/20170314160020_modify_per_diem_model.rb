class ModifyPerDiemModel < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :per_diems, column: :company_id
    remove_column :per_diems, :company_id, :integer

    add_reference :per_diems, :configurable, polymorphic: true
  end
end
