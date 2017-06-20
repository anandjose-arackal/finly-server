class Integrations::Quickbooks::SyncPaymentTypes < Integrations::Quickbooks::Base

  def pre_validate
    if user.blank? && params.blank?
      add_message :error, "Invalid parameters"
    end
  end


  def validate
    # what validation can we have here?
  end


  def process
    # this method also captures the different payment types from quickbooks and saves them in the database
    categories = adapter.categories
    categories.each do |category|
      additional_information = JSON.parse(category.quickbooks_additional_information)
      if FinlyIntegrationsConstants::CATEGORY_PAYMENT_TYPES.include? additional_information['account_type']
        cat = QuickbooksPaymentType.create(quickbooks_integration_type: category.quickbooks_integration_type,
                                           quickbooks_id: category.quickbooks_id,
                                           name: category.name,
                                           company_id: category.company_id,
                                           quickbooks_additional_information: category.quickbooks_additional_information)
      end
    end
  end

  def post_process
    add_message :success, "Payment types successfully synced"
  end
end
