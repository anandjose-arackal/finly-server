class AddSoftDeletableToPayment < ActiveRecord::Migration[5.2]
  def change
    Payment.migrate_to_paranoid
  end
end
