class AddApprovedAtToReport < ActiveRecord::Migration
  def change
    add_column :reports, :approved_at, :datetime
  end
end
