class AddPayrollCardEnabledToCardPrograms < ActiveRecord::Migration
  def change
    add_column :feature_subscriptions, :payroll_card_enabled, :boolean, default: false
    CardProgram.seed_data
  end
end
