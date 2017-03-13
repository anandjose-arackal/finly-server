class Expense::ExDistance::Create < Expense::ExDistance::Base

  attr_accessor :expense_params

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters passed"
    end
    if params[:expense].blank?
      messages[:error] << 'You have not provided any details to create an expense'
      return
    end
    distance_value = params[:expense][:distance_expense_attributes][:distance_attributes][:distance].to_d rescue nil
    if distance_value.present? and distance_value <= 0
      messages[:error] << 'Amount cannot be less than or equal to 0'
    end
  end

  def init
    self.expense_params = distance_expense_params
  end
end