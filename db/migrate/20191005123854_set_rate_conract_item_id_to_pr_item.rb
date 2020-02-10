class SetRateConractItemIdToPrItem < ActiveRecord::Migration[5.2]
  def change
    PurchaseRequestItem.all.find_each do |purchase_request_item|
      # Check for vendor with rate contract
      if purchase_request_item.vendor_id.present?
        rc_item_id = purchase_request_item.item.rate_contract_line_items.joins(:rate_contract).where("rate_contracts.vendor_id = ?", purchase_request_item.vendor_id).first.id rescue nil
        if rc_item_id.present?
          purchase_request_item.update(rate_contract_item_id: rc_item_id)
        end
      end
    end
  end
end
