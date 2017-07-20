class Admin::Users::Index < Admin::Users::Base

  attr_accessor :users, :company, :companies

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def authorize

  end

  def validate

  end

  def init
    self.users = User.all.unscoped
    self.companies = Company.all
  end

  def success
    params[:users] = users
    params[:companies] = companies
    Admin::Users::Index::UsersPresenter.new(user, params, messages)
  end

  class Admin::Users::Index::UsersPresenter < BaseOperation::BasePresenter::SuccessPresenter
    include HasScope

    attr_accessor :users, :companies, :paginated_users

    has_scope :company_id
    has_scope :filter_company_id
    has_scope :filter_search
    has_scope :filter_date_from
    has_scope :filter_date_to
    has_scope :created_between, using: [:start_date, :end_date], type: :hash
    has_scope :filter_role, type: :array
    has_scope :filter_state, type: :array
    has_scope :with_cards_having_card_program, type: :array
    has_scope :filter_card_number

    def init
      convert_scopes
      self.users = params[:users]
      self.users = apply_scopes(users, params)
      # self.paginated_users = users.paginate(page: params[:page], per_page: 30)
      self.paginated_users = users
      self.companies = params[:companies]
    end

    def convert_scopes
      ScopeUtils.fix_for_scoping(params, :filter_role, :array)
      ScopeUtils.fix_for_scoping(params, :filter_state, :array)
      ScopeUtils.fix_for_scoping(params, :with_cards_having_card_program, :array)
    end
  end

end