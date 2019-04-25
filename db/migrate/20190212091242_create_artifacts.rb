class CreateArtifacts < ActiveRecord::Migration[5.2]
  def change
    create_table :artifacts do |t|
      t.integer :resource_id
      t.string :resource_type
      t.string :attachment_file_name
      t.integer :attachment_file_size
      t.string :attachment_content_type
      t.datetime :attachment_updated_at
      t.text :description
      t.integer :company_id

      t.timestamps
    end
  end
end
