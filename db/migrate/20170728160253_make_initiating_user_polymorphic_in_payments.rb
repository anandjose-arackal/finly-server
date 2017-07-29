class MakeInitiatingUserPolymorphicInPayments < ActiveRecord::Migration
  def change
    add_column :payments, :initiating_user_type, :string
    add_column :payments, :receiving_user_type, :string
  end
end
