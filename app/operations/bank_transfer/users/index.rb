class BankTransfer::Users::Index < BankTransfer::Users::Base

  attr_accessor :users, :role_id

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    # initialize the role id for a particular user
    self.role_id = params[:role_id]
    if self.role_id.blank? && params[:view].present?
      if params[:view] == 'finance'
        params[:view] = 'finance_manager'
      end
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
    params[:with_application] = RequestStore.store[:current_app].to_s
  end

  def validate
    unless role_id.present?
      add_message :error, "User role not defined"
    end
  end

  def process
    # insert logic here for teams once that has been implemented in vendor payments
    case role_id
      when UserRole.id_for(:admin)
        self.users = user.company.users
      else
        self.users = []
    end
  end

  def success
    params[:users] = users
    BankTransfer::Users::Index::UsersPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::Index::UsersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :users

    has_scope :with_application

    def init
      self.users = params[:users]
      self.paginated_team = users.paginate(page: params[:page], per_page: 30)
    end
  end


end