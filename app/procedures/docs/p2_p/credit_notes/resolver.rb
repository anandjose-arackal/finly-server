class Docs::P2P::CreditNotes::Resolver < Resolver::API

  entity CreditNote

  def load(params)
    if user.vendor_payment_admin?
      admin_restricted_status_ids = [CreditNoteStatus.id_for(:draft)]
      credit_notes = CreditNote.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).or(user.credit_notes)
    elsif user.policy_user_roles.pluck(:user_role_id).uniq.present?
      credit_notes = CreditNote.associated_items(user, CreditNote.roles) || CreditNote.none
    else
      credit_notes = CreditNote.none
    end

    credit_notes
  end


end