class CreateFeatureSubscriptions < ActiveRecord::Migration
  def change
    create_table :feature_subscriptions do |t|
      t.integer :subscribable_id, index: true, null: false
      t.string :subscribable_type, index: true, null: false

      t.boolean :ocr_enabled, null: false, default: false
      t.boolean :d_code_assigned, null: false, default: false
      t.boolean :expense_management_enabled, null: false, default: false
      t.boolean :gift_card_enabled, null: false, default: false
      t.boolean :gift_voucher_enabled, null: false, default: false
      t.boolean :meal_card_enabled, null: false, default: false
      t.boolean :fuel_card_enabled, null: false, default: false
      t.boolean :medical_card_enabled, null: false, default: false

      t.timestamps null: false
    end

    Company.all.each do |c|
      if c.feature_subscription.blank?
        c.build_feature_subscription(expense_management_enabled: true).save
      end
    end
  end
end
