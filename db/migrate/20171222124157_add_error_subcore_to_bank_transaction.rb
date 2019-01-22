class AddErrorSubcoreToBankTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_transactions, :error_sub_code, :string
    add_column :payments, :retry_count, :integer
  end
end
