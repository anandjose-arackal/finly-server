class CreatePaymentFileDownloadedBadgeForPaymentRequests < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :payment_file_downloaded, :boolean, default: false
  end
end
