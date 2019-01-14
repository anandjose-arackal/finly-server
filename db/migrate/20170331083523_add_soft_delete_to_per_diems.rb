class AddSoftDeleteToPerDiems < ActiveRecord::Migration[4.2]
  def change
    add_column :per_diems, :is_deleted, :boolean, default: false
  end
end
