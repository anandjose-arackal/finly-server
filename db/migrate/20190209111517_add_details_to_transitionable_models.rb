class AddDetailsToTransitionableModels < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_payment_requests, :approved_at, :datetime
    add_column :purchase_orders, :submitted_at, :datetime
    add_column :purchase_orders, :approved_at, :datetime
    add_column :travel_requests, :booking_submitted_at, :datetime
    add_column :travel_requests, :booking_approved_at, :datetime
    add_column :invoices, :submitted_at, :datetime
    add_column :invoices, :approved_at, :datetime
  end
end