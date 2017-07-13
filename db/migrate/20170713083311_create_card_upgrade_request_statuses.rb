class CreateCardUpgradeRequestStatuses < ActiveRecord::Migration
  def change
    create_table :card_upgrade_request_statuses do |t|

      t.timestamps null: false
    end
  end
end
