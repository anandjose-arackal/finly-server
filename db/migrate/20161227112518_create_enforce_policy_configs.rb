class CreateEnforcePolicyConfigs < ActiveRecord::Migration[4.2]
  def change
    create_table :enforce_policies do |t|
      t.references :enforceable, polymorphic: true, index: true, null: false
      t.boolean :enabled

      t.timestamps null: false
    end
  end
end
