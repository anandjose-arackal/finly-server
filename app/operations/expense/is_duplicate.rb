class Expense::IsDuplicate < Expense::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:type].blank?
      add_message :error, 'Expense type not found'
      return
    end
  end

  def process
    case params[:type]
      when '1'
        # Manual

      when '3'
        # Distance

      when '4'
        # Time

      when '5'
        # PerDiem

      when '6'
        # Manual Multiple

      when '7'
        # Distance Multiple

      when '8'
        # Time Multiple

      when '9'
        # Per Diem Multiple

    end
  end

end