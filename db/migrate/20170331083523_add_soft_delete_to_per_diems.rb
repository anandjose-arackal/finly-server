class AddSoftDeleteToPerDiems < ActiveRecord::Migration
  def change
    add_column :per_diems, :is_deleted, :boolean, default: false
  end
end
