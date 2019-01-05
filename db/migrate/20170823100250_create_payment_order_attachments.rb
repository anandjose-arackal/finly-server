class CreatePaymentOrderAttachments < ActiveRecord::Migration[4.2]
  def change
    # creating payment order attachments
    create_table :payment_order_attachments do |t|
      t.attachment :attached_file

      t.timestamps null: false
    end

    add_reference :payment_order_attachments, :payment_order
    add_column :payment_order_attachments, :description, :text
  end
end
