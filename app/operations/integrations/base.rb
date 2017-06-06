class Integrations::Base < BaseOperation

  attr_accessor :company, :selected_user, :adapter

  def initialize(company, params)
    self.company = company
    self.params = params
  end

  def self.call(company, params)
    self.new(company, params).run
  end

  def init
    # sets up the connection for the sync with quickbooks
    self.selected_user = User.find_by(id: params[:id])
    auth = selected_user.authentications.quickbooks.first
    FinlyIntegrations.adapter = :quickbooks
    self.adapter = FinlyIntegrations.adapter
    adapter.setup_connection(auth)
  end

end