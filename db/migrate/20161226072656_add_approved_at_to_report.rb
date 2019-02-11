class AddApprovedAtToReport < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :approved_at, :datetime
  end
end
