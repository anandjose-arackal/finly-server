# this class with return all the addresses that belong to a particular 'parent'
# which can be anything from invoices to customers etc.

class Addresses::Index < Addresses::Base

  attr_accessor :addresses, :parent_id, :parent_type, :parent

  class Addresses::Index::AddressesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :addresses

    has_scope :filter_search

    def init
      self.addresses = params[:addresses]
      self.addresses = apply_scopes(self.addresses, params)
    end
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.parent_type = params[:parent_type]
    case self.parent_type
      when "Customer"
        self.parent_id = params[:parent_id]
        self.parent = user.company.customers.find_by(id: self.parent_id)
      else
        add_message :error, "Invalid parameters. Whose addresses are you looking for?"
    end
  end

  def validate
    if self.parent.blank?
      add_message :error, "Parent not found"
    end
  end

  def process
    self.addresses = self.parent.addresses
  end

  def success
    params[:addresses] = self.addresses
    Addresses::Index::AddressesPresenter.new(user, params, messages)
  end
end