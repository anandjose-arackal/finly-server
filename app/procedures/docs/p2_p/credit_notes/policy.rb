class Docs::P2P::CreditNotes::Policy < ApplicationPolicy

  def create?
    @user.has_policy_role?(UserRole.id_for(:credit_note_initiator))
  end

  def approve?
    @model.awaiting_approval? && @model.get_reviewers.include?(@user)
  end

  def update?
    ((@model.draft? || @model.retracted? || @model.rejected?) && @model.user_id == @user.id) || (@model.awaiting_approval? && @model.get_reviewers.include?(@user))
  end

  def index?
    @user.vendor_payment_admin? ||
        @user.has_policy_role?(UserRole.id_for(:credit_note_initiator)) ||
        @user.has_policy_role?(UserRole.id_for(:credit_note_reviewer)) ||
        @user.has_policy_role?(UserRole.id_for(:credit_note_auditor)) ||
        @user.is_bank_payment_request_initiator? ||
        @user.is_bank_payment_request_reviewer? ||
        @user.is_bank_payment_request_auditor? ||
        @user.is_bank_payment_request_creditor? ||
        @user.is_invoice_initiator? ||
        @user.is_invoice_reviewer? ||
        @user.is_invoice_auditor? ||
        @user.is_payment_agreement_initiator? ||
        @user.is_payment_agreement_reviewer? ||
        @user.is_payment_agreement_auditor? ||
        @user.is_po_invoice_initiator? ||
        @user.is_po_invoice_reviewer? ||
        @user.is_po_invoice_auditor? ||
        @user.is_non_po_invoice_initiator? ||
        @user.is_non_po_invoice_reviewer? ||
        @user.is_non_po_invoice_auditor? ||
        @user.is_agreement_invoice_initiator? ||
        @user.is_agreement_invoice_reviewer? ||
        @user.is_agreement_invoice_auditor?
  end

  def show?
    index? &&
        (@model.user_id == @user.id ||
            @user.vendor_payment_admin? ||
            ((CreditNoteStatus.all.pluck(:id) - [CreditNoteStatus.id_for(:draft)]).include?(@model.status_id) &&
                (@model.validate_if_reviewer(user) || @model.validate_if_auditor(user))
            ) ||
            (CreditNoteStatus.ids_for(:approved, :auto_approved, :partially_adjusted, :adjusted, :voided, :unadjusted).include?(@model.status_id) &&
                (@user.has_policy_role?(:purchase_order_initiator, @model) ||
                    @user.has_policy_role?(:purchase_order_reviewer, @model) ||
                    @user.has_policy_role?(:purchase_order_auditor, @model) ||
                    @user.has_policy_role?(:po_invoice_initiator, @model) ||
                    @user.has_policy_role?(:non_po_invoice_initiator, @model) ||

                    @user.has_policy_role?(:bank_payment_request_initiator, @model) ||
                    @user.has_policy_role?(:bank_payment_request_reviewer, @model) ||
                    @user.has_policy_role?(:bank_payment_request_auditor, @model) ||
                    @user.has_policy_role?(:bank_payment_request_creditor, @model) ||

                    @user.has_policy_role?(:payment_agreement_initiator, @model) ||
                    @user.has_policy_role?(:payment_agreement_reviewer, @model) ||
                    @user.has_policy_role?(:payment_agreemen_auditor, @model)
                )
            )
        )
  end

  def reject?
    @model.get_reviewers.include?(@user)
  end

  def submit?
    CreditNote.open_statuses.include?(@model.status_id) && @model.user_id == @user.id
  end

  def retract?
    @model.awaiting_approval? && @model.user_id == @user.id
  end

  def destroy?
    CreditNote.open_statuses.include?(@model.status_id) && @model.user_id == @user.id
  end

  def take_control?
    @user.vendor_payment_admin? && @model.awaiting_approval? && @model.get_reviewers.exclude?(@user)
  end

  def return_control?
    @user.vendor_payment_admin? && @model.awaiting_approval? && @model.taken_control? && @model.get_reviewers.include?(@user)
  end

  def void?
    CreditNoteStatus.ids_for(:approved, :auto_approved).include?(@model.status_id) && (@user.vendor_payment_admin? || @model.user_id == @user.id)
  end

  private

  def reviewing_user?
    reviewing_user_ids = @model.dlrms.pluck(:reviewer_id) + @model.dlrms.pluck(:forwarded_to_id)
    reviewing_user_ids.include?(@user.id)
  end

  def poc?
    @model.pocs.include?(@user)
  end

end