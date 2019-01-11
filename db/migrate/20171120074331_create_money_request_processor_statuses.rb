class CreateMoneyRequestProcessorStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :money_request_processor_statuses do |t|
      t.string :name, index: true, null: false

      t.timestamps null: false
    end
    MoneyRequestProcessorStatus.seed_data
  end
end
