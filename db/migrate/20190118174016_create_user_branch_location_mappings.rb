class CreateUserBranchLocationMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_branch_location_mappings do |t|
      t.references :user, foreign_key: true, null: false, type: :integer
      t.references :branch_location, foreign_key: true, null: false, type: :integer

      t.timestamps
    end
  end
end
