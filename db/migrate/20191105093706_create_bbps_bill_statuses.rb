class CreateBbpsBillStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :bbps_bill_statuses do |t|
      t.string :name

      t.timestamps
    end

    BbpsBillStatus.seed_data
  end
end
