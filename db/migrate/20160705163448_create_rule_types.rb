class CreateRuleTypes < ActiveRecord::Migration
  def change
    create_table :rule_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
