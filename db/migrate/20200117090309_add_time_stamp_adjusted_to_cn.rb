class AddTimeStampAdjustedToCn < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_notes, :last_adjusted_at, :datetime
  end
end
