class PolicyUserRoles::Destroy < PolicyUserRoles::Base
  attr_accessor :added_users, :role_id, :policy_user_role, :reviewer_type, :policy, :destroy_user_id

  def init
    id = params[:id] || params[:policy_user_role_id]
    self.policy_user_role = PolicyUserRoles::Index.(user, params).policy_user_roles.find_by(id: id) rescue nil
    self.reviewer_type = params[:reviewer_type]
    self.policy = Policy.find_by_id params[:policy_id]
    self.destroy_user_id = PolicyUserRole.find_by_id(params[:id]).user_id
  end

  def validate
    unless self.policy_user_role.present?
      add_message :error, 'Record not found'
    end
    # Do not destroy if user is set as reviewer in approval workflow
    # Destroy user from approval flow first
      validate_reviewer_in_approval_flow if %w(purchase_order_reviewer invoice_reviewer bank_payment_request_reviewer).include?(reviewer_type)
  end

  def process
    if self.policy_user_role.destroy
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
      when 'invoice_reviewer'
        provider = 'InvoiceProvider'
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
    level_ids = ReviewalLevel.where(id: policy.level_user_reviewer_mappings&.pluck(:level_id), associated_entity_type: provider)
    reviewer_ids += policy.level_user_reviewer_mappings.where(level_id: level_ids).pluck(:reviewer_id)
    return reviewer_ids&.uniq&.flatten&.compact
  end

end