class CreateCardRestrictionTemplates < ActiveRecord::Migration
  def change
    create_table :card_restriction_templates do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
