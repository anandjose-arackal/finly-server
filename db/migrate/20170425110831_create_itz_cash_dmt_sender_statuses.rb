class CreateItzCashDmtSenderStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :itz_cash_dmt_sender_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    if Company.count > 0
      ItzCashDmtSenderStatus.seed_data
    end
    add_column :itz_cash_dmt_senders, :status_id, :integer, references: 'ItzCashDmtSenderStatus', null: false, index: true, foreign_key: true
  end
end
