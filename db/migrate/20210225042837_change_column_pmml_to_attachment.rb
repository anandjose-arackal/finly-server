class ChangeColumnPmmlToAttachment < ActiveRecord::Migration[6.0]
  def change
    remove_column :ml_models, :pmml
    add_attachment :ml_models, :pmml
  end
end
