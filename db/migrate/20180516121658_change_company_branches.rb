class ChangeCompanyBranches < ActiveRecord::Migration[4.2]
  def change
    add_reference :company_branches, :company, index: true, foreign_key: true
    add_column :company_branches, :address_1, :string
    add_column :company_branches, :address_2, :string
    add_column :company_branches, :city, :string
    add_reference :company_branches, :state
    add_column :company_branches, :country, :string
    add_column :company_branches, :pin, :string
    remove_column :company_branches, :address, :text

    #
    # GSTIN:
    #     GSTIN Type:
    #               Address 1:
    #     Address 2:
    #     City:
    #     State:
    #     Country:
    #     Pin:
    #
    # company_branches = CompanyBranch.all
    #
    # company_branches.each do |company_branch|
    #   company_branch.update(company_id: company_branch.collect_company_detail.company_id)
    # end
    #
    # remove_reference :company_branches, :collect_company_detail, index: true, foreign_key: true
  end
end
