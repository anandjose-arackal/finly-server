class Docs::ExpenseManagement::Reports::Resolver < Resolver::API

  entity Report

  # Todo - this was quickly implemented for macros. This is not thought through well and might require a re-write
  # Currently this will only return company reports or personal reports
  def load(params)
    reports = nil
    if user.admin?(:em)
      reports = Report.where(company_id: user.company_id)
    else
      reports = user.reports
    end

    reports
  end


end