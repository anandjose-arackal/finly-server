class CreateRuleTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :rule_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
