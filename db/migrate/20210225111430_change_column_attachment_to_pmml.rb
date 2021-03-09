class ChangeColumnAttachmentToPmml < ActiveRecord::Migration[6.0]
  def change
    add_column :ml_models, :pmml, :text, limit: 4294967295
    remove_column :ml_models, :pmml_file_name
    remove_column :ml_models, :pmml_content_type
    remove_column :ml_models, :pmml_file_size
    remove_column :ml_models, :pmml_updated_at
  end
end
