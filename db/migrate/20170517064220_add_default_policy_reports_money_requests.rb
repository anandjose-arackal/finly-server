class AddDefaultPolicyReportsMoneyRequests < ActiveRecord::Migration
  def change
    Report.where(policy_id: nil).each do |report|
      report.update(policy_id: report.user.company.default_policy.id)
    end
    MoneyRequest.where(policy_id: nil).each do |money_request|
      money_request.update(policy_id: money_request.user.company.default_policy.id)
    end
    change_column_null :reports, :policy_id, false
    change_column_null :money_requests, :policy_id, false
  end
end
