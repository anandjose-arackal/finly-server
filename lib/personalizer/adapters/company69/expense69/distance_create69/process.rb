class Personalizer::Adapters::Company69::Expense69::DistanceCreate69::Process < Personalizer::Adapters::Company69::Expense69::Base

  def validate
    expense_attributes = op_instance.expense_params
    user_distance = expense_attributes&.dig(:distance_expense_attributes, :distance_attributes, :value)&.to_d
    maps_distance = expense_attributes&.dig(:distance_expense_attributes, :maps_distance_attributes, :value)&.to_d
    locations = expense_attributes&.dig(:distance_expense_attributes, :locations_attributes)
    type = expense_attributes&.dig(:distance_expense_attributes, :type_id)
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

  def pre_process
    expense_params = self.op_instance.expense_params
    expense_params[:reimbursable] = false
    self.op_instance.expense_params = expense_params
  end

end