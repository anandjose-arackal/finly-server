class AddFormIdToMlModels < ActiveRecord::Migration[6.0]
  def change
    add_column :ml_models, :form_id, :string, index: true
  end
end
