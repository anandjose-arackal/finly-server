class AddAllowDeleteToPaymentOrderAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_order_attachments, :allow_delete, :boolean, default: true
    add_index :payment_order_attachments, :allow_delete
  end
end
