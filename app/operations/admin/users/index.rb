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

    attr_accessor :users, :companies

    has_scope :filter_company_id
    has_scope :filter_search
    has_scope :created_between, using: [:start_date, :end_date], type: :hash
    has_scope :filter_role
    has_scope :filter_state
    has_scope :with_cards_having_card_program

    def init
      self.users = params[:users]
      self.users = apply_scopes(users, params)
      self.companies = params[:companies]
    end
  end

end