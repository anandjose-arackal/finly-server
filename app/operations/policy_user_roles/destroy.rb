class PolicyUserRoles::Destroy < PolicyUserRoles::Base
  attr_accessor :added_users, :role_id, :policy_user_role, :reviewer_type, :policy, :destroy_user_id, :associated_lurms

  def init
    id = params[:id] || params[:policy_user_role_id]
    self.policy_user_role = PolicyUserRoles::Index.(user, params).policy_user_roles.find_by(id: id) rescue nil
    self.reviewer_type = params[:reviewer_type]
    self.policy = Policy.find_by_id params[:policy_id]
    self.destroy_user_id = PolicyUserRole.find_by_id(params[:id]).user_id

  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    unless self.policy_user_role.present?
      add_message :error, 'Record not found'
    end
    # Do not destroy if user is set as reviewer in approval workflow
    # Destroy user from approval flow first
      validate_reviewer_in_approval_flow if %w(purchase_order_reviewer invoice_reviewer bank_payment_request_reviewer).include?(reviewer_type)
  end

  def pre_process
    self.associated_lurms = get_associated_reviewal_mappings
  end

  def process

    if self.policy_user_role.destroy
      if associated_lurms.present?
        associated_lurms.map(&:destroy)
        add_message :success, "Associated User Reviewer Mappings Successfully Removed "
      end
      add_message :success, "Successfully removed user"
    else
      add_message :error, "Couldn't removed user"
    end
  end

  private

  def validate_reviewer_in_approval_flow
    if self.reviewer_type.present?
      case reviewer_type
      when 'purchase_order_reviewer'
        provider = 'PurchaseOrderProvider'
        reviewer_ids =  associated_entity_type_reviewers(provider)
      # when 'invoice_reviewer'
      #   provider = 'InvoiceProvider'
      #   reviewer_ids = associated_entity_type_reviewers(provider)
      when 'po_invoice_reviewer'
        provider = 'PoInvoiceProvider'
        reviewer_ids = associated_entity_type_reviewers(provider)
      when 'non_po_invoice_reviewer'
        provider = 'NonPoInvoiceProvider'
        reviewer_ids = associated_entity_type_reviewers(provider)
      when 'bank_payment_request_reviewer'
        provider = 'BankPaymentRequestProvider'
        reviewer_ids = associated_entity_type_reviewers(provider)
      end
      if reviewer_ids.include?(destroy_user_id)
        add_message :error, 'User is already present in the approval flow. Please remove from there first.'
        return
      end
    end
  end

  def validate_reviewer_in_lurm
    self.policy = policy_user_role.policy_id if self.policy.blank?

  end

  def associated_entity_type_reviewers(provider)
    reviewer_level_ids = policy.levels.exclude_deleted.where(associated_entity_type: provider).pluck(:id)
    reviewer_ids = LevelReviewerMapping.non_deleted.with_level_id(reviewer_level_ids).pluck(:reviewer_id)
    # lurm reviewers
    level_ids = ReviewalLevel.where(id: policy.level_user_reviewer_mappings&.pluck(:level_id), associated_entity_type: provider)&.pluck(:id)&.uniq
    reviewer_ids += policy.level_user_reviewer_mappings.where(level_id: level_ids).pluck(:reviewer_id)
    return reviewer_ids&.uniq&.flatten&.compact
  end

  # Find all LevelUserReviewerMapping for the user who have initiatior role in the document provider
  def get_associated_reviewal_mappings
    if self.reviewer_type.present? && self.policy_user_role.present?
      if self.reviewer_type.include?("initiator")
        provider = self.reviewer_type.camelize.gsub("Initiator", "Provider")
        level_ids = ReviewalLevel.where(policy_id: policy.id, associated_entity_type: provider)&.pluck(:id)
        associated_lurms = policy.level_user_reviewer_mappings.where(level_id: level_ids, user_id: policy_user_role&.user.id)
        return associated_lurms
      end
    end

  end

end