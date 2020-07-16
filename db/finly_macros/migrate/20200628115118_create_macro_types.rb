class CreateMacroTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :macro_types do |t|
      t.string :name, index: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
    MacroType.seed_data
  end
end
