require 'finly_integrations/adapters/quickbooks_adapter'

class Integrations::Quickbooks::Base < Integrations::Base

  attr_accessor :adapter

  def authorized_user_types
    [:company_admin]
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