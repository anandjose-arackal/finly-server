class UpdateTotalAmountInPr < ActiveRecord::Migration[5.2]
  def change
    PurchaseRequest.all.each do |purchase_request|
      purchase_request.update_total_amount
      # if purchase_request.errors.present?
        # puts purchase_request.errors.full_messages
      # end
    end
  end
end
