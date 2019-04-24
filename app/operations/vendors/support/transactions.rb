class Vendors::Support::Transactions < Vendors::Support::Base
  attr_accessor :procurements, :vendor

  class Vendors::Support::Transactions::TransactionsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :transactions, :paginated_transactions, :count, :vendor

    def init
      self.vendor = params[:vendor]
      page = params[:page] || 1
      per_page = params[:per_page] || 30

      self.transactions = self.vendor.receiving_payments.with_receiving_user_type(self.vendor.class.name).with_receiving_account_type("BankAccount").with_application(RequestStore.store[:current_app]).successful_and_failed_only
      self.count = self.transactions.count
      self.paginated_transactions = self.transactions.paginate(page: page, per_page: per_page)
    end
  end

  def init
    self.vendor = Vendors::Show.(user, params).vendor rescue nil
  end

  def validate
    unless self.vendor.present?
      add_message :error, "Vendor Not Found"
    end
  end

  def success
    params[:vendor] = self.vendor
    Vendors::Support::Transactions::TransactionsPresenter.new(user, params, messages)
  end
end