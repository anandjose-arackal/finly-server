class User::GroupEntitiesLogin < User::Base

  attr_accessor :email_mobile, :companies, :email, :mobile_number, :group

  class User::GroupEntitiesLogin::CompaniesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :companies

    def init
      self.companies = params[:companies]
    end

  end

  def pre_validate

  end

  def init
    self.email_mobile = params[:email_mobile] || params[:email]
    self.user = User.find_for_database_authentication(username: self.email_mobile)
    self.email = self.user&.email
    self.mobile_number = self.user&.mobile_number
    self.company = self.user&.company
  end

  def validate
    # validating password of the user first things first
    unless StringUtils.to_bool(RequestStore.store[:skip_password])
      if params[:password].blank?
        add_message :error, 'Please enter your password before logging in'
        return
      end
      unless user&.valid_password?(params[:password])
        add_message :error, 'The email / mobile or password you entered is incorrect'
        return
      end
    end

    if user.blank?
      add_message :error, "The email / mobile or password you entered is incorrect"
      return
    end

    if self.company.blank?
      add_message :error, "The email / mobile or password you entered is incorrect"
      return
    end

    unless self.company.group_entity_structure_enabled?
      add_message :error, "Your corporate doesn't have group entity feature enabled"
      return
    end

    Rails.logger.fatal "ACTUAL CURRENT USER"
    Rails.logger.fatal RequestStore.store[:actual_current_user].present?
    Rails.logger.fatal RequestStore.store[:actual_current_user].inspect
    if RequestStore.store[:actual_current_user].present?
      add_message :error, "Group Entity switch disabled during user delegation"
      return
    end
  end

  def process
    self.group = self.company.group
    group_companies = self.group.companies.where(status_id: CompanyStatus.ids_for(:active, :partial_block, :hidden))
    users = User.with_company_id(group_companies.pluck(:id)).with_email_or_mobile_number(self.email, self.mobile_number)
    self.companies = Company.with_id(users.pluck(:company_id))
  end

  def success
    params[:companies] = self.companies
    User::GroupEntitiesLogin::CompaniesPresenter.new(user, params, messages)
  end

end