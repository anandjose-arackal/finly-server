class Docs::ExpenseManagement::ReportProcessorGroups::Resolver < Resolver::API

  entity Report

  # Todo - this was quickly implemented for macros. This is not thought through well and might require a re-write
  # Currently this will only return company reports or personal reports
  def load(params)
    report_processor_groups = nil
    if user.admin?(:em)
      report_processor_groups = ReportProcessorGroup.where(company_id: user.company_id)
    else
      report_processor_groups = ReportProcessorGroup.where(company_id: user.company_id).created_by_user(user.id)
    end
    report_processor_groups
  end


end