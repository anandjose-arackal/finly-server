class CreateMoneyRequestStatuses < ActiveRecord::Migration
  def change
    create_table :money_request_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
