class Personalizer::Adapters::Company69::Expense69::DistanceUpdate69::Process < Personalizer::Adapters::Base

  def validate
    expense_attributes = op_instance.updated_expense_params
    expense = op_instance.expense
    expense.assign_attributes(expense_attributes)
    user_distance = expense.distance_expense.distance&.value
    maps_distance = expense.distance_expense.maps_distance&.value
    locations = expense.distance_expense.locations
    type = expense.distance_expense.type_id
    return unless [nil, DistanceExpenseType.id_for(:distance)].include?(type)
    unless maps_distance.present? and maps_distance > 0 and locations&.size > 1
      add_message :error, 'You need to enter atleast 2 way points to create Distance Expense'
      return
    end
    if (user_distance - maps_distance) > 3
      add_message :error, 'Reported distance cannot be +3 KMS from Maps Distance'
      return
    end
    if (user_distance - maps_distance) < -3
      add_message :error, 'Reported distance cannot be -3 KMS from Maps Distance'
      return
    end
  end

end