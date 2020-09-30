# returns users which can be invited or whose roles can be defined after invitation.
# 
class UserOnboarding::BuildUsersForImport < BaseOperation
  attr_accessor :policy_user_roles, :user_roles, :users, :common_mails, :new_mails, :input_emails, :bulk_assign, :common_emails,
                :new_emails, :existing_emails


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
    self.bulk_assign = params[:bulk_assign]
    self.input_emails = bulk_assign[:user_emails]
    # used after invitation
    # when updating policy with user roles
    # 
    if bulk_assign[:user_ids]
      # this one is used after invitation. if users are to be configured in some other policies
      self.users = user.company.users.with_id(bulk_assign[:user_ids])

      # used for invitation
    elsif bulk_assign[:user_emails]

      violating_emails = []
      bulk_assign[:user_emails].each do |email|
        if (email =~ Constants::VALID_EMAIL_FORMAT).nil?
          violating_emails << email
        end
      end

      if violating_emails.present?
        add_message :error, "Invalid emails were found. Please correct them"
        add_message :notice, violating_emails
        return false
      end


      if user.company.feature_subscription.group_entity_structure
        gc = current_company.group
        # TODO prevent sql injection DONE
        # this one tells if there are users in group companies
        # if to check user also present in current gc company, we do the check later in common_users
        self.users = gc.companies.where.not(id: current_company.id).select('users.*').joins(:users).where('users.email in (?)', bulk_assign[:user_emails]) rescue User.none
      else
        # this tells if there are users already invited
        self.users = user.company.users.with_email(bulk_assign[:user_emails])
      end

      # this tells which users are to be invited. comes from FE
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
    if self.users.blank?
      add_message :error, "No valid users were provided. Probably they are already invited."
      return
    end
  end

  def success
    params[:users] = self.users
    UserOnboarding::BuildUsersForImport::SuccessPresenter.new(user, params, messages)
  end

  class UserOnboarding::BuildUsersForImport::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :users

    def init
      self.users = params[:users]
    end
  end

  private

  def common_users
    # this will mostly be called if group entity enabled.
    # we will find the users attributes from other companies and set it to new company
    user_list = []
    company_id = user.company_id
    self.users.each do |user|
      next if self.existing_emails.include? user.email # skip if email already exist in current gc company, even if present in other gc company
      user.default_company_id = company_id
      user_attributes_clone = user.attributes.with_indifferent_access.except("invitation_token")
      if user_attributes_clone["id"].present?
        user_attributes_clone[:profile_attributes] = User.where(id: user_attributes_clone["id"]).first&.profile&.attributes&.with_indifferent_access.except("id")
      end
      user_list << user_attributes_clone
    end

    user_list
  end

  def new_users
    # for configuring new users
    user_list = []

    self.new_emails.each do |email|
      user_list << {email: email, default_password: true}
    end
    user_list
  end

  def process_users
    self.existing_emails = user.company.users.with_email(bulk_assign[:user_emails]).pluck :email

    # finds email already invited or in other group companies. You can also use this to tell FE if the user already invited
    self.common_emails = self.input_emails & self.users.pluck(:email)
    # finds which users are to be actually invited
    self.new_emails = self.input_emails - (user.company.users.pluck(:email) + self.common_emails)


    # return if self.new_mails.blank? and self.common_emails.blank?

    user_list = []
    if current_company.feature_subscription.group_entity_structure
      user_list = common_users + new_users
    else
      user_list = new_users
    end

    maximum_users = UserToggle.new(current_user).maximum_users
    if maximum_users.present? and maximum_users > 0
      existing_users_count = current_company.users.filter_state([User::ACTIVE, User::PENDING]).count
      new_users = user_list.size
      if existing_users_count + new_users >= maximum_users
        add_message :error, "Error inviting users. You have reached the maximum users you can invite in your plan"
        return
      end
    end

    # if user in group entity, then simply create a new user
    # if new user, then invite them
    # 
    newly_created_users = []
    user_list.uniq.each do |list|
      options = list
      options.delete("id")
      options[:company_id] = user.company_id
      options[:default_company_id] = user.company_id
      options = setup_user_panel_subscription(options)
      options = setup_user_profile(options)

      if current_company.feature_subscription.group_entity_structure and common_emails.include?(list[:email])
        u = User.new options
        u.save(:validate => false)
        UsersWithGroupMapping.create(user: u, company: current_company, group: current_company.group) if u.id.present?
      else
        u = User.invite! options
      end

      newly_created_users << u
    end

    update_user_panel_subscription

    # get all emails of newly created users and see if they exist in the new company and return them
    all_emails = newly_created_users.pluck(:email) + self.common_emails + self.existing_emails
    user.company.users.where(email: all_emails)
  end

  def setup_user_panel_subscription(options)
    if RequestStore.store[:vp_onboarding]
      add_message :message, "VP ONBOARDING"
      options[:user_panel_subscription_attributes] = {yes_bank_account_transfer: true}
      return options
    elsif RequestStore.store[:em_onboarding]
      add_message :message, "EM ONBOARDING"
      options[:user_panel_subscription_attributes] = {expense_management: true}
      return options
    end
  end

  def setup_user_profile(options)
    if options[:profile_attributes].nil?
      options[:profile_attributes] = {employee_id: nil}
    end
    options
  end

  def update_user_panel_subscription
    users = user.company.users.with_email(self.common_emails + self.existing_emails)
    users.each do |u|
      if RequestStore.store[:vp_onboarding]
        add_message :message, "VP ONBOARDING"
        u.user_panel_subscription.update(yes_bank_account_transfer: true) unless u.user_panel_subscription.yes_bank_account_transfer
      elsif RequestStore.store[:em_onboarding]
        add_message :message, "EM ONBOARDING"
        u.user_panel_subscription.update(expense_management: true) unless u.user_panel_subscription.expense_management
      end
    end
  end

end