class CreateCreditNoteStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_note_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
