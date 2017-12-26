class AddErrorSubcoreToBankTransaction < ActiveRecord::Migration
  def change
    add_column :bank_transactions, :error_sub_code, :string
    add_column :payments, :retry_count, :integer
  end
end
