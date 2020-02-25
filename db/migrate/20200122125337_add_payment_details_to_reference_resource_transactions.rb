class AddPaymentDetailsToReferenceResourceTransactions < ActiveRecord::Migration[5.2]
  def change
    # add_column :bbps_yes_bank_transactions, :reference_payment_id, :integer, references: "Payment", foreign_key: true, index: true
    # add_column :kotak_bank_transactions, :reference_payment_id, :integer, references: "Payment", foreign_key: true, index: true
    # add_column :icici_bank_transactions, :reference_payment_id, :integer, references: "Payment", foreign_key: true, index: true
    # add_column :payments, :reference_payment_id, :integer, references: "Payment", foreign_key: true, index: true
    # add_column :virtual_account_transactions, :reference_payment_id, :integer, references: "Payment", foreign_key: true, index: true
    # add_column :reports, :reference_payment_id, :integer, references: "Payment", foreign_key: true, index: true
    # add_column :card_transactions, :reference_payment_id, :integer, references: "Payment", foreign_key: true, index: true
    # add_column :yes_bank_transactions, :reference_payment_id, :integer, references: "Payment", foreign_key: true, index: true
    # add_column :money_requests, :reference_payment_id, :integer, references: "Payment", foreign_key: true, index: true
  end
end
