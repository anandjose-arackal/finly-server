class SaveTheReceiptsPdfToDocumentSlices < ActiveRecord::Migration
  def change
    if Rails.env.production?
      user = User.first
      Receipt.all.each do |receipt|
        if receipt.is_pdf?
          DocumentSlice::Create.(user.id, {receipt_id: receipt.id})
        end
      end
    end
  end
end
