class CreateCardAssignRequestStatuses < ActiveRecord::Migration
  def change
    create_table :card_assign_request_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
