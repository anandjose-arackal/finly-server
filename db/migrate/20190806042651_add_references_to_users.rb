class AddReferencesToUsers < ActiveRecord::Migration[5.2]
  def change
      add_column :users, :cost_center_id, :integer, referneces: :cost_center, index:true, foreign_key: true
      add_column :users, :department_id, :integer, references: :department, index: true,foreign_key: true
      add_column :users, :location_id, :integer, references: 'BranchLocation', foreign_key: true, index: true
  end
end
