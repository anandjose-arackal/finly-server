class Integrations::Quickbooks::SyncCategories < Integrations::Base

  def pre_validate
    if user.blank? && params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    # sets up the connection for the sync with quickbooks
    self.selected_user = User.find_by(id: params[:id])
    auth = selected_user.authentications.quickbooks.first
    FinlyIntegrations.adapter = :quickbooks
    adapter = FinlyIntegrations.adapter
    adapter.setup_connection(auth)
  end

  def validate

  end

  def process
    # call the Quickbooks adapter method that retrieves the categories from Quickbooks online repo and saves it locally
    categories = adapter.categories
    categories.each do |category|
      category.save
    end
  end

  def post_process
    add_message :success, "Categories successfully synced"
  end

end