class SaveTheReceiptsPdfToDocumentSlices < ActiveRecord::Migration
  def change
    if Rails.env.production?
      Receipt.all.each do |receipt|
        user = receipt.user
        if receipt.is_pdf?
          DocumentSlice::Create.(user.id, {receipt_id: receipt.id})
        end
      end
    end
  end
end
