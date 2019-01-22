class AddCompanyIdToAssignCardRequests < ActiveRecord::Migration[4.2]
  def change
    add_reference :card_assign_requests, :company, index: true, foreign_key: true
    CardAssignRequest.all.update_all(company_id: 1)
    change_column_null :card_assign_requests, :company_id, false
  end
end
