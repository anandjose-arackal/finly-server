class Streamsets::Transactions::Vendors < BaseOperation
  attr_accessor :vendors

  def pre_validate

  end

  def init
    op = ::Vendors::Index.(user, params)
    if op.failure?
      add_message :error, op.messages[:error]
      return
    end

    self.vendors = op.vendors

  end

  def success
    params[:vendors] = self.vendors
    Streamsets::Transactions::VendorsPresenter.new(user, params, messages)
  end

  class Streamsets::Transactions::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :vendors, :paginated_vendors

    def init
      self.vendors = params[:vendors]
      page = params[:page] || 1
      per_page = params[:per_page] || 50
      self.paginated_vendors = self.vendors.paginate(page: page, per_page: per_page)
    end
  end


end