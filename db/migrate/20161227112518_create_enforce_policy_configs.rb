class CreateEnforcePolicyConfigs < ActiveRecord::Migration
  def change
    create_table :enforce_policy do |t|
      t.references :enforceable, polymorphic: true, index: true, null: false
      t.boolean :enabled

      t.timestamps null: false
    end
  end
end
