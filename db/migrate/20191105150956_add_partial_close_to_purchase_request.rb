class AddPartialCloseToPurchaseRequest < ActiveRecord::Migration[5.2]
  def change
    PurchaseRequestStatus.seed_data
  end
end
