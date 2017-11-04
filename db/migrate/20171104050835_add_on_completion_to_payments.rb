class AddOnCompletionToPayments < ActiveRecord::Migration
  def change
    add_column :payments,:post_operation, :text
    add_column :payments,:post_operation_payload, :text
    add_column :payment_orders,:post_operation, :text
    add_column :payment_orders,:post_operation_payload, :text
    add_reference :report_processor_groups, :payment_order, index: true, foreign_key: true
  end
end
