# File used to validate the current set of dlrms
# Usually called before updating the document and setting the dlrms, and prevents user saving the document

class ReviewalManager::DocumentReviewalMappings::ValidationUpdate < ReviewalManager::DocumentReviewalMappings::Base
  attr_accessor :document, :dlrms, :policy, :violations_present, :reviewal_levels, :document_reviewer_mappings_params

  def init
    self.document = params[:reviewal_document]
    self.document_reviewer_mappings_params = params[:document_reviewer_mappings_params]
    # DLRM wont' be there
    # self.dlrms = self.document.document_level_reviewer_mappings.includes(:level, :reviewer)
    self.policy = user.company.policies.non_deleted.find_by id: self.document.policy_id
    self.violations_present = !!params[:violations_present]

    provider_name = self.document.get_default_provider
    if self.policy.present?
      self.reviewal_levels = self.policy.levels.with_associated_entity_type(provider_name).non_deleted.reorder(:level_number)
    end
  end

  def validate
    unless self.document.present?
      add_message :error, 'Document not found'
    end
  end

  def process
    # Check
    amount = get_document_amount
    if self.reviewal_levels.present?
      self.reviewal_levels.each do |level|
        if level.level_user_reviewer_mappings.with_user_id(user.id).with_threshold(amount).with_exception(violations_present).present?
          valid_reviewer_ids = level.level_user_reviewer_mappings.with_user_id(user.id).with_threshold(amount).with_exception(violations_present).pluck(:reviewer_id)
        else
          valid_reviewer_ids = level.level_reviewer_mappings.non_deleted.with_threshold(amount).with_exception(violations_present).pluck(:reviewer_id)
        end

        valid_reviewer_ids.compact!
        level_reviewer_data = get_level_reviewer_data(level.id)

        if valid_reviewer_ids.present?
          if level_reviewer_data.present?
            unless level_reviewer_data[:reviewer_id].present? && valid_reviewer_ids.include?(level_reviewer_data[:reviewer_id].to_i)
              level_details = ['Level', level.level_number.to_s, level.name].join(" - ")
              add_message :error, "Cannot set selected reviewer for '#{level_details}' as amount doesn't fall within threshold range of reviewer"
            end
          else
            level_details = ['Level', level.level_number.to_s, level.name].join(" - ")
            add_message :error, "Please select a reviewer for '#{level_details}' as amount doesn't fall within threshold range of reviewer"
          end
        else
          if level_reviewer_data[:reviewer_id].present?
            add_message :error, "Cannot set selected reviewer for '#{level_details}'"
          end
        end
      end
    end
  end

  def get_document_amount
    # Different kind of documents have base amount stored in different attributes which is used in 
    # threshold in level reviewer mapping
    amount = 0

    case document.class.name
    when 'PurchaseOrder'
      document.process_line_item_calculation(false)
      amount = document.balance_amount&.value rescue 0
    when 'MoneyRequest'
      amount = document&.total_amount
    when 'Invoice'
      amount = document&.net_amount&.value rescue 0
    when 'Report'
      amount = document&.total_amount rescue 0
    when 'BankPaymentRequest'
      amount = document&.payment_order&.amount_requested&.value rescue 0
    # when 'TravelRequest'
    #   amount = 0
    else
      amount = 0
    end
    amount
  end


  private

  def get_level_reviewer_data(level_id)
    self.document_reviewer_mappings_params.each do |drm|
      if drm[:level_id].to_i == level_id
        return drm
      end
    end

    return nil
  end
end