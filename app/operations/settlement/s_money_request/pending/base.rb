class Settlement::SMoneyRequest::Pending::Base < BaseOperation

  def authorized_user_types
    [:admin, :auditor, :finance_manager]
  end

end