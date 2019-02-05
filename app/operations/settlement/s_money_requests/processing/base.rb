class Settlement::SMoneyRequests::Processing::Base < BaseOperation

  def authorized_user_types
    [:admin, :auditor, :finance_manager]
  end

end