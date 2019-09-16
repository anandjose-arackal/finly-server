class RenameColumnsInBankPaymentRequest < ActiveRecord::Migration[5.2]
  def change
    rename_column :payments, :opt_attempts, :otp_attempts

  end
end
