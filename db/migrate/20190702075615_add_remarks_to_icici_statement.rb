class AddRemarksToIciciStatement < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_statements, :remarks, :text
  end
end
