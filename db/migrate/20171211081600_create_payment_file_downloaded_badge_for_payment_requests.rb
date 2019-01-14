class CreatePaymentFileDownloadedBadgeForPaymentRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_requests, :payment_file_downloaded, :boolean, default: false
  end
end
