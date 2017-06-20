class Integrations::Quickbooks::Base < Integrations::Base

  attr_accessor :adapter

  def init
    # this initializes the adapter and sets up the connection for all syncing
    auth = user.authentications.first
    FinlyIntegrations.adapter = :quickbooks
    self.adapter = FinlyIntegrations.adapter
    # setting up the connection for the sync
    adapter.setup_connection(auth)
  end
end