class PolicyUserRoles::BulkUsersForImport < PolicyUserRoles::Base
  attr_accessor :policy_user_roles, :user_roles, :users, :common_mails, :new_mails


  def init
    if bulk_assign[:user_ids]
      self.users = user.company.users.with_id(bulk_assign[:user_ids])
    elsif bulk_assign[:user_emails]
      if feature_subscription.group_entity
        gc = current_company.group
        self.users = gc.companies.without(current_company).joins(:users).
                                                                        select('
                                                                          companies.*,
                                                                          users.email
                                                                        ').
                                                                        where(email: bulk_assign[:email])
      else
        self.users = user.company.users.with_email(bulk_assign[:user_emails])
        self.input_emails = bulk_assign[:user_emails]
      end
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
      user.company_id = company_id
      user_list << user.dup  
    end

    user_list.update_all company_id: user.company_id
  end

  def new_users
    user_list = []

    self.new_emails.each do |email|
      user_list << user.new(email: email)
    end
    user_list
  end

  def process_users
    self.common_emails = self.input_emails & self.users.pluck(:email)
    self.new_emails = self.input_emails - self.users.pluck(:email)

    user_list = []
    if current_company.feature_subscription.group_entity
      user_list = common_users + new_users
    else
      user_list = new_users
    end

    User.import user_list

    User.where(email: self.common_emails)
  end
end