class AddOriginalSourceToReceiptEmail < ActiveRecord::Migration
  def change
    add_attachment :receipt_emails, :original_source
  end
end
