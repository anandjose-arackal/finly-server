class AddAssociatedAccountToCustomerAccountTransaction < ActiveRecord::Migration[4.2]
  def change
    add_reference :customer_account_transactions, :associated_object, polymorphic: true, index: {name: 'indx_cstmer_acc_tranxs_on_assoc_acc_type_and_assoc_acc_id'}
    remove_reference :customer_account_transactions, :virtual_account_transaction, index: {name: 'indx_custmer_acc_tranxs_on_virtual_acc_tranx_id'}, foreign_key: true
  end
end
