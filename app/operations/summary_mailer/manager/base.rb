class SummaryMailer::Manager::Base < BaseOperation

  def authorized_user_types
    [:manager, :finance_manager]
  end

end