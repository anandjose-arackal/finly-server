class Vendors::Index < Vendors::Base

  attr_accessor :vendors

  class Vendors::Index::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendors, :count, :paginated_vendors

    has_scope :filter_name_search

    def init
      self.vendors = params[:vendors]
      self.vendors = apply_scopes(self.vendors, params)

      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_vendors = self.vendors.paginate(page: page, per_page: per_page).include_details
      self.count = self.vendors.count
    end

  end

  def init
    self.vendors = user.company.yes_bank_vendors.non_deleted
  end

  def validate
    #
  end

  def success
    params[:vendors] = self.vendors
    Vendors::Index::VendorsPresenter.new(user, params, messages)
  end

end