class ChangeRateHandlingInTimeAndDistanceConfig < ActiveRecord::Migration
  def change
    # store the existing time and distance expense configs in a temporary variable
    time_rates = {}
    distance_rates = {}
    TimeExpenseConfig.all.where.not(rate_per_hour: nil) do |tec|
      time_rates[tec.id] = tec.rate_per_hour
    end
    DistanceExpenseConfig.all.where.not(rate_per_km: nil) do |dec|
      distance_rates[dec.id] = dec.rate_per_km
    end
    remove_column :time_expense_configs, :rate_per_hour, :decimal
    remove_column :distance_expense_configs, :rate_per_km, :decimal
    add_column :time_expense_configs, :rate_id, :integer, references: "Amount"
    add_column :time_expense_configs, :period_id, :integer, references: "Period"
    add_column :distance_expense_configs, :rate_id, :integer, references: "Amount"
    add_column :distance_expense_configs, :distance_unit_id, :integer, references: "PhysicalUnit"

    # creating periods that correspond to hour
    Period.create(name: "Hour")

    # resetting the time rates for all the TimeExpenseConfigs
    time_rates.each do |k, v|
      DistanceExpenseConfig.find_by(id: k).update(rate_attributes: {value: v}, period_id: Period.id_for(:hour))
    end
    # resetting the distance rates for all DistanceExpenseConfigs
    distance_rates.each do |k, v|
      TimeExpenseConfig.find_by(id: k).update(rate_attributes: {value: v}, distance_unit_id: PhysicalUnit.kilometre_id)
    end
  end
end
