class CreateReportStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :report_statuses do |t|
      t.string :name, null: false
      t.integer :order

      t.timestamps null: false
    end
  end
end
