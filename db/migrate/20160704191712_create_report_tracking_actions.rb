class CreateReportTrackingActions < ActiveRecord::Migration
  def change
    create_table :report_tracking_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
