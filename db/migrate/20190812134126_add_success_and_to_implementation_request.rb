class AddSuccessAndToImplementationRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_implementation_requests, :success_items, :integer, index: true, default: 0
    add_column :admin_implementation_requests, :failed_items, :integer, index: true, default: 0
  end
end
