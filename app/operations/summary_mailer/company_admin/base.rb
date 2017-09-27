class SummaryMailer::CompanyAdmin::Base < BaseOperation

  def authorized_user_types
    [:company_admin]
  end

end