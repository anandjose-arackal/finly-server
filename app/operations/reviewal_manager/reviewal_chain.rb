class ReviewalManager::ReviewalChain < ReviewalManager::Base
  attr_accessor :document, :provider_names,
                :chain, :policy,
                :levels, :provider_name

  # In params
  # policy_id needs to be present
  def init
    self.document = params[:reviewal_document]
    self.provider_name = params[:provider_name] || self.document&.get_default_provider
    self.chain = []
    self.provider_names = %w( PurchaseOrderProvider InvoiceProvider ReportProvider MoneyRequestProvider BankPaymentRequestProvider TravelRequestProvider TravelRequestBookingProvider )
    policy_id = params[:policy_id]

    self.policy = ::Policy::Index.(user, params).policies.with_id(policy_id).first rescue nil
    # self.policy = user.company.policies.with_application(:vp).with_id(policy_id).first rescue nil
  end

  def validate
    unless provider_names.include? provider_name
      add_message :error, 'Invalid Document Provided'
      return
    end
  end

  def process
    unless self.policy.present?
      return
    end

    # Find over ridden users for a policy level
    self.levels = self.policy.levels.with_entity_type(provider_name).order(:level_number)

    levels.each do |level|
      if level.level_user_reviewer_mappings.present?
        mappings = level.level_user_reviewer_mappings
      else
        mappings = level.level_reviewer_mappings.non_deleted
      end


      selected_reviewer = document.document_level_reviewer_mappings.with_level_ids(level.id).with_policy_ids(policy.id).first
      level_data = {
          level_number: level.level_number,
          level_id: level.id,
          reviewers: mappings
      }
      if selected_reviewer.present?
        level_data[:selected_reviewer] = selected_reviewer.reviewer
      end

      self.chain.push(level_data)
    end
  end

  def success
    params[:chain] = self.chain
    ReviewalManager::ReviewalChain::IndexPresenter.new(user, params, messages)
  end

  class ReviewalManager::ReviewalChain::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :chain

    def init
      self.chain = params[:chain]
    end
  end
end