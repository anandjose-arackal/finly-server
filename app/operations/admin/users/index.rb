class Admin::Users::Index < Admin::Users::Base

  attr_accessor :users, :company

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
    self.users = User.all.unscoped
  end

  def success
    Admin::Users::Index::UsersPresenter.new(user, {users: users}, messages)
  end

  class Admin::Users::Index::UsersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :users

    has_scope :filter_company_id
    has_scope :filter_search
    has_scope :created_between, using: [:start_date, :end_date], type: :hash


    def init
      self.users = apply_scopes(params[:users], params)
    end
  end

end