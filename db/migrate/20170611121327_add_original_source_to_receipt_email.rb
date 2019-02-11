class AddOriginalSourceToReceiptEmail < ActiveRecord::Migration[4.2]
  def change
    add_attachment :receipt_emails, :original_source
  end
end
