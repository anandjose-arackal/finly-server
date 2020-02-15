# params {
#   reviewal_document: document, # Optional if provider_name is provided
#   provider_name: provider_name, # Optional if reviewal_document if provided
#   policy_id: policy_id, # Mandatory
#   violation_present: true/false # returns result based on violations
# }
# Return possible levels w/ reviewers and their thresholds for the passed values
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

    self.provider_names = %w( PurchaseOrderProvider PoInvoiceProvider NonPoInvoiceProvider AgreementInvoiceProvider ReportProvider MoneyRequestProvider BankPaymentRequestProvider TravelRequestProvider TravelRequestBookingProvider YesBankVendorProvider PurchaseRequestProvider PaymentAgreementProvider BbpsBillerSubscriptionProvider BbpsBillAutofetchedProvider BbpsBillNonAutofetchedProvider CreditNoteProvider )

    policy_id = params[:policy_id] || params['policy_id'] || document.policy_id
    # self.policy = ::Policy::Index.(user, params).policies.with_id(policy_id).first rescue nil
    self.policy = user.company.policies.with_id(policy_id).first rescue nil
  end

  def validate
    unless provider_names.include? provider_name
      add_message :error, 'Invalid Document Provided'
      return
    end

    unless policy.present?
      add_message :error, 'Invalid Policy'
      return
    end
  end

  def process
    # If policy not present, return, as some documents policy is not present during creation
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
        mappings = level.level_user_reviewer_mappings.with_user_id(user.id).with_exception(violations_present).includes(:reviewer)
      else
        mappings = level.level_reviewer_mappings.with_exception(violations_present).non_deleted.includes(:reviewer)
      end
      if self.document.present?
        selected_reviewer_from_dlrm = document.document_level_reviewer_mappings.with_level_ids(level.id).with_policy_ids(policy.id)
        selected_reviewer = selected_reviewer_from_dlrm.first if selected_reviewer_from_dlrm.length == 1
        timestamp = selected_reviewer_from_dlrm.first&.updated_at
      else
        selected_reviewer = nil
        timestamp = nil
      end
      level_data = {
          level_number: level.level_number,
          level_id: level.id,
          level_name: level.name,
          timestamp: timestamp,
          reviewers: mappings,
          reviewer_data: get_mapping_data(mappings)
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

  private

  def get_mapping_data(mappings)
    mappings = mappings.as_json
    result = []
    unique_reviewer_ids = mappings.map {|item| item['reviewer_id']}.uniq

    unique_reviewer_ids.each do |reviewer_id|

      sample = mappings.select {|item| item['reviewer_id'] == reviewer_id }[0]
      min = mappings.select{|item| item['reviewer_id'] == reviewer_id}.min_by {|item| item['threshold']}['threshold']
      compare_max = mappings.select{|item| item['reviewer_id'] == reviewer_id}.max_by {|item| item['threshold']}['threshold']

      thresholds = mappings.select {|item| (item['reviewer_id'] != reviewer_id) && (item['threshold'] > compare_max) }&.map {|item| item['threshold']}

      if thresholds.empty?
        max = 99999999999999
      else
        max = thresholds.min
      end

      reviewer = User.find_by id: reviewer_id

      data = {
          reviewer_id: reviewer_id,
          reviewer_name: reviewer&.name,
          reviewer: reviewer,
          threshold: sample['threshold'],
          id: sample['id'],
          exception: sample['exception'],
          min: min,
          max: max
      }

      result.push(data)
    end
    result
  end
end