class MakeInitiatingUserPolymorphicInPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :initiating_user_type, :string
    add_column :payments, :receiving_user_type, :string
  end
end
