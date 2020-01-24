class CreateFormDependencyTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :form_dependency_types do |t|
      t.string :name, index: true, null: false

      t.timestamps
    end
    FormDependencyType.seed_data
  end
end
