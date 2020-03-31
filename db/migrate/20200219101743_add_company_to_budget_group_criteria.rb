class AddCompanyToBudgetGroupCriteria < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :company_id, :integer, references: "Company", foreign_key: true, index: true

    # adding company_id to all reports from expenses
    Report.find_each(batch_size: 1000) do |report|
      report.update_columns(company_id: report.user&.company_id)
    end
  end
end
