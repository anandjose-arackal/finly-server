class Admin::Companies::Index < Admin::Companies::Base

  attr_accessor :companies

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
    self.companies = Company.all
  end

  def success
    Admin::Companies::Index::CompaniesPresenter.new(user, {companies: companies}, messages)
  end

  class Admin::Companies::Index::CompaniesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :companies

    has_scope :filter_search
    has_scope :created_between, using: [:start_date, :end_date], type: :hash


    def init
      self.companies = apply_scopes(params[:companies], params)
    end
  end

end
