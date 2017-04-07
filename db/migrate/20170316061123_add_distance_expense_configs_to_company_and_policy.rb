class AddDistanceExpenseConfigsToCompanyAndPolicy < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      unless company.distance_expense_config.present?
        company.build_distance_expense_config(enabled: false).save
      end
      unless company.time_expense_config.present?
        company.build_time_expense_config(enabled: false).save
      end
      unless company.per_diem_expense_config.present?
        company.build_per_diem_expense_config(enabled: false).save
      end
    end

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
