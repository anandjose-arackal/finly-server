class Expense::ExDistance::Create < Expense::ExDistance::Base


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
    distance_value = params[:expense][:distance_expense_attributes][:distance].to_d rescue nil
    if amount_value.present? and amount_value <= 0
      messages[:error] << 'Amount cannot be less than or equal to 0'
    end
  end

  def init

  end
end