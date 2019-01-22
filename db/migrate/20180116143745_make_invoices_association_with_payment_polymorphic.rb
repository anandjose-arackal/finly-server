class MakeInvoicesAssociationWithPaymentPolymorphic < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :parent_type, :string, polymorphic: true
    add_column :payments, :parent_id, :integer, polymorphic: true
  end
end
