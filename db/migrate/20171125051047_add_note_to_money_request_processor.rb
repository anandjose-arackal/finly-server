class AddNoteToMoneyRequestProcessor < ActiveRecord::Migration
  def change
    add_column :money_request_processor_mappings, :note, :text
  end
end
