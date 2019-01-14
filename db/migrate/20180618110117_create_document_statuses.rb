class CreateDocumentStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :document_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
