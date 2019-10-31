# returns users which can be invited or whose roles can be defined after invitation.
# 
class UserOnboarding::BuildUsersForImport < BaseOperation
  attr_accessor :policy_user_roles, :user_roles, :users, :common_mails, :new_mails, :input_emails, :bulk_assign, :common_emails, 
                :new_emails


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
      if user.company.feature_subscription.group_entity_structure
        gc = current_company.group
        # TODO prevent sql injection
        # this one tells if there are users in group companies
        self.users = gc.companies.without(current_company).select('users.*').joins(:users).where('users.email in (?)', bulk_assign[:email]) rescue User.none
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
    # this will mostly be called if group entity enabled.
    # we will find the users attributes from other companies and set it to new company
    user_list = []
    company_id = user.company_id
    self.users.each do |user|
      user.default_company_id = company_id
      user_list << user.attributes.with_indifferent_access
    end

    user_list
  end

  def new_users
    # for configuring new users
    user_list = []

    self.new_emails.each do |email|
      user_list << {email: email}
    end
    user_list
  end

  def process_users
    # finds email already invited or in other group companies. You can also use this to tell FE if the user already invited
    self.common_emails = self.input_emails & self.users.pluck(:email)
    # finds which users are to be actually invited
    self.new_emails = self.input_emails - user.company.users.pluck(:email)


    # return if self.new_mails.blank? and self.common_emails.blank?

    user_list = []
    if current_company.feature_subscription.group_entity_structure
      user_list = common_users + new_users
    else
      user_list = new_users
    end

    # if user in group entity, then simply create a new user
    # if new user, then invite them
    # 
    newly_created_users = []
    user_list.each do |list|
      options = list
      options[:company_id] = user.company_id
      if current_company.feature_subscription.group_entity_structure and common_emails.include?(list[:email])
        u = User.create options
        UsersWithGroupMapping.create(user: u, company: current_company, group: current_company.group)
      else
        u = User.invite! options
      end

      newly_created_users << u
    end

    # get all emails of newly created users and see if they exist in the new company and return them
    all_emails = newly_created_users.pluck(:email)
    user.company.users.where(email: all_emails)
  end
end