class MigrateOldAcceptingItemAmountData < ActiveRecord::Migration[5.2]
  def change
    InwardDocumentItem.joins(:purchase_order_item).where(accepting_item_amount_id: nil).each do |inward_document_item|
      amount = inward_document_item.per_unit_price * inward_document_item.accepted rescue nil
      if amount.present?
        inward_document_item.create_accepting_item_amount(currency_id: 1, value: amount)
      end
    end
  end
end
