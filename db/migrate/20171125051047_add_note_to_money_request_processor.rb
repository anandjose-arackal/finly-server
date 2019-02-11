class AddNoteToMoneyRequestProcessor < ActiveRecord::Migration[4.2]
  def change
    add_column :money_request_processor_mappings, :note, :text
  end
end
