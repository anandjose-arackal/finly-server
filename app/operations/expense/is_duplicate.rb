class Expense::IsDuplicate < Expense::Base
  attr_accessor :expense

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

  def init
    self.expense = Expense::Show.(user, params)&.expense
  end

  def process
    case params[:type]
      when '1'
        # Manual
        Expense::Manual::IsDuplicate.(user, expense: self.expense)
      when '3'
        # Distance
        Expense::Distance::IsDuplicate.(user, expense: self.expense)
      when '4'
        # Time
        Expense::Time::IsDuplicate.(user, expense: self.expense)
      when '5'
        # PerDiem
        Expense::PerDiem::IsDuplicate.(user, expense: self.expense)
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