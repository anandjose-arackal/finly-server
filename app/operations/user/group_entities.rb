class User::GroupEntities < User::Base

  attr_accessor :companies, :email, :mobile_number, :group, :company

  class User::GroupEntities::CompaniesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :companies

    def init
      self.companies = params[:companies]
    end

  end

  def init
    self.email = user.email
    self.mobile_number = user.mobile_number
    self.company = self.user.company
    self.group = self.company.group
  end

  def validate
    if self.company.blank?
      add_message :error, "Company not found"
      return
    end

    if self.group.blank?
      add_message :error, "Your corporate doesn't have group entity feature enabled"
      return
    end

    unless user.company.group_entity_structure_enabled?
      add_message :error, "Your corporate doesn't have group entity feature enabled"
      return
    end

    if RequestStore.store[:actual_current_user].present?
      add_message :error, "Group Entity switch disabled during user delegation"
      return
    end
  end

  def process
    group_companies = self.group.companies.where(status_id: CompanyStatus.ids_for(:active, :partial_block, :hidden))
    users = ActsAsTenant.without_tenant do
      User.with_company_id(group_companies.pluck(:id)).with_email_or_mobile_number(self.email, self.mobile_number)
    end
    self.companies = Company.with_id(users.pluck(:company_id))
  end

  def success
    params[:companies] = self.companies
    User::GroupEntities::CompaniesPresenter.new(user, params, messages)
  end
end