class ChangeTypeColumnInsideIciciStatements < ActiveRecord::Migration[5.2]
  def change
    rename_column :icici_statements, :type, :transaction_type
  end
end
