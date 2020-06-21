class AddDetailsToBbpsModels < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :refreshed_at, :datetime
    add_column :bbps_biller_subscriptions, :auto_fetch_enabled, :boolean, default: true
    add_column :bbps_biller_subscriptions, :biller_response, :text
    add_column :bbps_biller_subscriptions, :last_bill_generated_at, :datetime
    add_column :bbps_biller_subscriptions, :last_bill_due_date, :date
    add_column :bbps_biller_subscriptions, :last_bill_bill_date, :date

    add_column :bbps_bills, :generated_at, :datetime
    add_column :bbps_bills, :biller_response, :text

    BbpsBillerSubscription.all.each do |sub|
      bill = sub.bbps_bills.reorder(:created_at).last

      next if bill.blank?
      update_params = {
          refreshed_at: bill.created_at,
          last_bill_generated_at: bill.created_at,
          last_bill_due_date: bill.due_date.present? && bill.due_date.to_s != "9999-01-01" ? bill.due_date : nil,
          last_bill_bill_date: bill.bill_date.present? && bill.bill_date.to_s != "0000-01-01" ? bill.bill_date : nil
      }
      sub.update(update_params)
    end
  end
end
