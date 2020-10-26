class ChangeBbpsBillFields < ActiveRecord::Migration[5.2]
  def change
    change_column :bbps_bills, :api_response, :text, limit: 16777215
  end
end
