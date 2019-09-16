class AddBillableAmountToInwardDocumentItems < ActiveRecord::Migration[5.2]
  def change
    add_column :inward_document_items, :billable_amount, :decimal
    add_column :inward_document_items, :order_amount, :decimal
    add_column :inward_document_items, :previously_billed_amount, :decimal
  end
end
