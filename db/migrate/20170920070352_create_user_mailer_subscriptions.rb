class CreateUserMailerSubscriptions < ActiveRecord::Migration
  def change
    create_table :user_mailer_subscriptions do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.boolean :report_instant_mailer, index: true
      t.boolean :report_scheduled_mailer, index: true
      t.boolean :money_request_instant_mailer, index: true
      t.boolean :money_request_scheduled_mailer, index: true
      t.boolean :personal_summary, index: true
      t.boolean :manager_report_summary, index: true
      t.boolean :manager_money_request_summary, index: true
      t.boolean :admin_report_summary, index: true
      t.boolean :admin_money_request_summary, index: true

      t.timestamps null: false
    end
  end
end
