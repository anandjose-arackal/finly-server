require 'finly_integrations/adapters/quickbooks_adapter'

# this will be an async operation because the syncing will happen in the abckground
class Integrations::Quickbooks::Base < BaseOperation

  attr_accessor :adapter

  def authorized_user_types
    [:company_admin, :finance_manager]
  end

  def pre_validate
    if company.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end

    if user.authentications.valid.empty?
      add_message :error, "You haven't connected to quickbooks yet, please connect your account and try again"
    end
  end

  def initialize(company, params, user)
    self.company = company
    self.params = params
    self.user = user
  end

  def self.call(company, params, user)
    self.new(company, params, user).run
  end

  def init
    # this initializes the adapter and sets up the connection for all syncing
    auth = user.authentications.first
    FinlyIntegrations.adapter = :quickbooks
    self.adapter = FinlyIntegrations.adapter
    # setting up the connection for the sync
    adapter.setup_connection(auth)
  end
end