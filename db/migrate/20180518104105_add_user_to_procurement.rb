class AddUserToProcurement < ActiveRecord::Migration
  def change
    add_reference :procurements, :user, index: true, foreign_key: true
    add_reference :procurements, :company, index: true, foreign_key: true

    add_reference :purchase_orders, :user, index: true, foreign_key: true
  end
end
