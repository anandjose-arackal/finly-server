class AddDistanceExpenseConfigsToCompanyAndPolicy < ActiveRecord::Migration[4.2]
  def change
    Policy.all.each do |policy|
      unless policy.distance_expense_config.present?
        policy.build_distance_expense_config(enabled: false).save
      end
      unless policy.time_expense_config.present?
        policy.build_time_expense_config(enabled: false).save
      end
      unless policy.per_diem_expense_config.present?
        policy.build_per_diem_expense_config(enabled: false).save
      end
    end
  end
end
