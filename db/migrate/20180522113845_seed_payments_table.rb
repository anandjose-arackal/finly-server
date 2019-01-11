class SeedPaymentsTable < ActiveRecord::Migration[4.2]
  def change
    PaymentStatus.seed_data
  end
end
