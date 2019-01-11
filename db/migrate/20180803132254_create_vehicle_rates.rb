class CreateVehicleRates < ActiveRecord::Migration[4.2]
  def change
    create_table :vehicle_rates do |t|
      t.string :vehicle_name, null: false
      t.integer :rate_id, references: 'Amount', index: true, null: false, foreign_key: true
      t.integer :distance_unit_id, references: 'PhysicalUnit', index: true, foreign_key: true, null: false
      t.references :policy, index: true, foreign_key: true, null: true
      t.boolean :is_deleted, index: true, default: false

      t.timestamps null: false
    end
    DistanceExpenseConfig.all.each do |distance_expense_config|
      next unless distance_expense_config.enabled and distance_expense_config.rate&.value.present?
      vehicle_rate = VehicleRate.new(
          {
              vehicle_name: 'Vehicle',
              policy: distance_expense_config.policy,
              rate: Amount.new(value: distance_expense_config.rate.value, currency_id: distance_expense_config.rate.currency_id),
              distance_unit_id: PhysicalUnit.kilometre_id
          })
      unless vehicle_rate.save
        raise "#{vehicle_rate.errors.full_messages}"
        return
      end
    end
    add_column :distance_expenses, :vehicle_rate_id, :integer, references: 'VehicleRate', index: true, foreign_key: true
    add_column :distance_expenses, :distance_rate_id, :integer, references: 'Amount', index: true, foreign_key: true
    add_column :distance_expenses, :distance_unit_id, :integer, references: 'PhysicalUnit', index: true, foreign_key: true
    DistanceExpense.all.each do |distance_expense|
      next if distance_expense.expense.blank?
      next if distance_expense.expense.report_id.blank?
      policy = distance_expense.expense.report.policy
      next unless policy.distance_expense_config.enabled
      vehicle_rate = policy.vehicle_rates.first
      if vehicle_rate.blank?
        raise "Vehicle rate not found #{distance_expense.id}"
      end
      rate_value = policy.distance_expense_config.rate&.value
      unit_id = policy.distance_expense_config.distance_unit_id
      distance_expense.update vehicle_rate: vehicle_rate, distance_rate: Amount.new(value: rate_value, currency_id: 1), distance_unit_id: unit_id
    end
  end
end