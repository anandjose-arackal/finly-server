class Dashboard::ExpenseManagement::Base < Dashboard::Base


  private

  def get_relevant_view
    if user.admin?
      view = 'admin'
    elsif user.finance_manager?
      view = 'finance'
    elsif user.manager?
      view = 'manager'
    else
      view = 'presonal'
    end
  end
end