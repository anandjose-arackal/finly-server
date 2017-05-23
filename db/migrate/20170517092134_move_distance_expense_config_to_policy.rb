class MoveDistanceExpenseConfigToPolicy < ActiveRecord::Migration
  def change
    add_column :distance_expense_configs, :policy_id, :integer, index: true, foreign_key: true, null: false
    add_column :time_expense_configs, :policy_id, :integer, index: true, foreign_key: true, null: false
    add_column :per_diem_expense_configs, :policy_id, :integer, index: true, foreign_key: true, null: false

    DistanceExpenseConfig.all.each do |config|
      if config.parent_type == 'Company'
        policy = Company.find_by(id: config.parent_id).default_policy
      else
        policy = Policy.find_by(id: config.parent_id)
      end
      config.update(policy: policy, parent_id: nil, parent_type: nil)
    end

    TimeExpenseConfig.all.each do |config|
      if config.parent_type == 'Company'
        policy = Company.find_by(id: config.parent_id).default_policy
      else
        policy = Policy.find_by(id: config.parent_id)
      end
      config.update(policy: policy, parent_id: nil, parent_type: nil)
    end

    PerDiemExpenseConfig.all.each do |config|
      if config.parent_type == 'Company'
        policy = Company.find_by(id: config.parent_id).default_policy
      else
        policy = Policy.find_by(id: config.parent_id)
      end
      config.update(policy: policy, parent_id: nil, parent_type: nil)
    end

    remove_column :distance_expense_configs, :parent_id
    remove_column :distance_expense_configs, :parent_type

    remove_column :time_expense_configs, :parent_id
    remove_column :time_expense_configs, :parent_type

    remove_column :per_diem_expense_configs, :parent_id
    remove_column :per_diem_expense_configs, :parent_type
  end
end
