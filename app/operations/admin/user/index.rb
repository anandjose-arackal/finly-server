class Admin::User::Index < Admin::User::Base

  attr_accessor :users

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def authorize

  end

  def validate

  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
    self.users = company.users
  end

  def success
    Admin::User::Index::UsersPresenter.new(user, {users: users}, messages)
  end

  class Admin::Company::Index::CompaniesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :users

    has_scope :filter_company_id
    has_scope :filter_search
    has_scope :created_between, using: [:start_date, :end_date], type: :hash


    def init
      self.users = apply_scopes(params[:users], params)
    end
  end

end