class PolicyUserRoles::BulkUsersForImport < PolicyUserRoles::Base
  attr_accessor :policy_user_roles, :user_roles, :users, :common_mails, :new_mails, :input_emails


  def pre_validate
    if params[:bulk_assign].blank?
      add_message :error, "No data was sent for processing."
      return
    end

    if params[:bulk_assign][:user_ids].blank? and params[:bulk_assign][:user_emails].blank?
      add_message(:error, "No Users selected.")
      return
    end

  end

  def init

    self.input_email = bulk_assign[:user_emails]
    # used after invitation
    # when updating policy with user roles
    # 
    if bulk_assign[:user_ids]
      self.users = user.company.users.with_id(bulk_assign[:user_ids])

      # used for invitation
      #
    elsif bulk_assign[:user_emails]
      if user.company.feature_subscription.group_entity_structure
        gc = current_company.group
        # prevent sql injection
        self.users = gc.companies.without(current_company).joins(:users).where('users.email in (?)', bulk_assign[:email]) rescue Company.none
      else
        self.users = user.company.users.with_email(bulk_assign[:user_emails])
      end

      self.input_emails = bulk_assign[:user_emails]
    end

  end

  def validate
    if bulk_assign[:user_ids]
      self.users = self.users
    elsif bulk_assign[:user_emails]
      self.users = process_users
    end

  end

  def process
    return false if self.users.blank?
  end

  def success
    params[:users] = self.users
    PolicyUserRoles::BulkUsersForImport::SuccessPresenter.new(user, params, messages)
  end

  class PolicyUserRoles::BulkUsersForImport::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :users

    def init
      self.users = params[:users]
    end
  end

  private

  def common_users
    user_list = []
    company_id = user.company_id
    self.users.each do |user|
      user.default_company_id = company_id
      user_list << user.attributes.with_indifferent_access
    end

    user_list
  end

  def new_users
    user_list = []

    self.new_emails.each do |email|
      user_list << {email: email}
    end
    user_list
  end

  def process_users
    self.common_emails = self.input_emails & self.users.pluck(:email)
    self.new_emails = self.input_emails - user.company.users.pluck(:email)


    return if self.new_mails.blank? and self.common_emails.blank?

    user_list = []
    if current_company.feature_subscription.group_entity_structure
      user_list = common_users + new_users
    else
      user_list = new_users
    end

    newly_created_users = []
    user_list.each do |list|
      options = list
      options[:company_id] = user.company_id
      if common_emails.include? list[:email]
        u = User.create options
      else
        u = User.invite! options
      end

      newly_created_users << u
    end

    user.company.where(email: newly_created_users.pluck(:email))
  end
end