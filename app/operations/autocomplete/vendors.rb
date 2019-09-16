class Autocomplete::Vendors < BaseOperation

  attr_accessor :vendors

  def init
    params[:filter_search] = params[:filter_search].strip if params[:filter_search].present?
  end

  def process
    params[:filter_approved] = true
    params[:non_deleted] = true
    params[:filter_active] = true
    op = ::Vendors::Index.(user, params)
    if op.success?
      self.vendors = op.vendors
    end
  end

  def success
    params[:vendors] = self.vendors
    Autocomplete::Vendors::VendorsPresenter.new(user, params, messages)
  end

  class Autocomplete::Vendors::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendors, :paginated_vendors

    def init
      self.vendors = params[:vendors]

      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_vendors = self.vendors.paginate(page: page, per_page: per_page)
    end
  end
end