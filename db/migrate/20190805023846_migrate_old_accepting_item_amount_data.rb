class MigrateOldAcceptingItemAmountData < ActiveRecord::Migration[5.2]
  def change
    InwardDocumentItem.where(accepting_item_amount_id: nil).where.not(purchase_order_item_id: nil).each do |inward_document_item|
      amount = inward_document_item.per_unit_price * inward_document_item.accepted rescue nil
      if amount.present?
        # inward_document_item.create_accepting_item_amount(currency_id: 1, value: amount)
        ai_amount = Amount.create(currency_id: 1, value: amount)
        inward_document_item.update_column('accepting_item_amount_id', ai_amount.id)
      end
    end
  end
end
