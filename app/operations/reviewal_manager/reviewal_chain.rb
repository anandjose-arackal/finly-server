class ReviewalManager::ReviewalChain < ReviewalManager::Base
  attr_accessor :document, :provider_names,
                :chain, :policy,
                :levels, :provider_name, :violations_present

  # In params
  # policy_id needs to be present
  def init
    self.document = params[:reviewal_document]
    self.provider_name = params[:provider_name] || self.document&.get_default_provider
    self.violations_present = !!params[:violations_present]
    self.chain = []
    self.provider_names = %w( PurchaseOrderProvider InvoiceProvider ReportProvider MoneyRequestProvider BankPaymentRequestProvider TravelRequestProvider TravelRequestBookingProvider YesBankVendorProvider )
    policy_id = params[:policy_id]

    # self.policy = ::Policy::Index.(user, params).policies.with_id(policy_id).first rescue nil
    self.policy = user.company.policies.with_id(policy_id).first rescue nil
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
    self.levels = self.policy.levels.non_deleted.with_entity_type(provider_name).reorder(:level_number)

    params[:filter_associated_entity_type] = provider_name
    params[:filter_policy_id] = self.policy.id
    self.levels = ReviewalLevels::Index.(user, params).reviewal_levels

    levels.each do |level|
      if level.level_user_reviewer_mappings.with_user_id(user.id).with_exception(violations_present).present?
        mappings = level.level_user_reviewer_mappings.with_user_id(user.id).with_exception(violations_present)
      else
        mappings = level.level_reviewer_mappings.with_exception(violations_present).non_deleted
      end
      if self.document.present?
        selected_reviewer_from_dlrm = document.document_level_reviewer_mappings.with_level_ids(level.id).with_policy_ids(policy.id)
        selected_reviewer = selected_reviewer_from_dlrm.first if selected_reviewer_from_dlrm.length == 1
      else
        selected_reviewer = nil
      end
      level_data = {
          level_number: level.level_number,
          level_id: level.id,
          level_name: level.name,
          reviewers: mappings
      }
      if selected_reviewer.present?
        level_data[:selected_reviewer] = selected_reviewer.reviewer
        level_data[:selected_reviewer_threshold] = selected_reviewer.threshold
      end
      if mappings.present?
        self.chain.push(level_data)
      end
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