class AddMissingColumnsToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    unless column_exists?(:purchase_requests, :location_id, :integer)
      add_column :purchase_requests, :location_id, :integer
    end
    unless column_exists?(:purchase_requests, :department_id, :integer)
      add_column :purchase_requests, :department_id, :integer
    end
    unless column_exists?(:purchase_requests, :policy_id, :integer)
      add_column :purchase_requests, :policy_id, :integer
    end
    unless column_exists?(:purchase_requests, :controlling_level_id, :integer)
      add_column :purchase_requests, :controlling_level_id, :integer
    end
    unless column_exists?(:purchase_requests, :company_id, :integer)
      add_column :purchase_requests, :company_id, :integer
    end
  end
end
