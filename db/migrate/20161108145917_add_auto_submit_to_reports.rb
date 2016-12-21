class AddAutoSubmitToReports < ActiveRecord::Migration
  def change
    add_column :reports, :auto_submit, :boolean, null: false, default: false
    add_column :reports, :auto_approve, :boolean, null: false, default: false
  end
end
