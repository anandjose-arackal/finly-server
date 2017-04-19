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
    params[:companies] = companies
    Admin::Companies::Index::CompaniesPresenter.new(user, params, messages)
  end

  class Admin::Companies::Index::CompaniesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    include HasScope

    attr_accessor :companies

    has_scope :filter_search
    has_scope :created_between, using: [:start_date, :end_date], type: :hash
    has_scope :filter_ocr
    has_scope :filter_cards
    has_scope :filter_date_from
    has_scope :filter_date_to


    def init
      self.companies = params[:companies]
      self.companies = apply_scopes(companies, params)
    end
  end

end
