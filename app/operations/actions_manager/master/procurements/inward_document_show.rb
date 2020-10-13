class ActionsManager::Master::Procurements::InwardDocumentShow < ActionsManager::Master::Base

  register_handle :proc_inward_document_show
  register_actions [:update_document, :editable, :delete]

  def initialize(user=nil, params={})
    super
    result = ::Procurements::InwardDocuments::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end

    self.inward_document = result.inward_document
    self.procurement = self.inward_document.procurement
  end


  def update_document
    return false unless user.company.feature_subscription.grn_enabled || user.company.feature_subscription.srn_enabled
    
    # editable
    if (self.inward_document.id == self.procurement.inward_documents.last.id) && (self.procurement.documents&.first&.class&.name != "Invoice")
      unless all_accepted?
        true
      end
    end
  end

  def editable
    return false unless user.company.feature_subscription.grn_enabled || user.company.feature_subscription.srn_enabled
    # edit button only appears after we have updated it with some items 
    # do not show edit button while the doc has just been created
    # after doc has been updated with some delivered items, show the edit button

    if (self.inward_document.id == self.procurement.inward_documents.last.id) && (self.procurement.documents&.first&.class&.name != "Invoice")
      unless all_accepted?
        if user.company.feature_subscription.grn_enabled
          e = inward_document.items.map {|i| i.delivered == 0}
        elsif user.company.feature_subscription.srn_enabled
          e = inward_document.items.map {|i| i.billable_amount.to_i == 0}
        elsif user.company.feature_subscription.grn_enabled && user.company.feature_subscription.srn_enabled
          e = inward_document.items.map {|i| i.delivered == 0}
          e += inward_document.items.map {|i| i.billable_amount.to_i == 0}
        end
        unless e.include? true
          if user.company.feature_subscription.grn_enabled
            e = inward_document.items.map {|i| i.quantity >= i.accepted}
          elsif user.company.feature_subscription.srn_enabled
            e = inward_document.items.map {|i| i.order_amount >= i.previously_billed_amount}
          elsif user.company.feature_subscription.grn_enabled && user.company.feature_subscription.srn_enabled
            e = inward_document.items.map {|i| i.quantity >= i.accepted}
            e += inward_document.items.map {|i| i.order_amount >= i.previously_billed_amount}
          end
          e = inward_document.items.map {|i| i.quantity >= i.accepted}
          e.include? true
        end
      end
    end
  end

  def delete
    return false unless user.company.feature_subscription.grn_enabled || user.company.feature_subscription.srn_enabled
    if self.procurement.documents&.first&.class&.name != "Invoice"
      unless self.inward_document.id != self.procurement.inward_documents.last.id
        true
      end
    elsif self.procurement.documents&.first&.class&.name == "Invoice" &&  self.procurement.documents&.first&.voided?
      true
    end
  end

  # def delete
  #   true
  # end

  # # alias_method :invoice, :input

  # def more_details_button
  #   true
  # end

  # def send_mail
  #   true
  # end

  # def export_items
  #   true
  # end

  # def submit
  #   document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
  # end
  
  # def reject
  #   invoice.processing? && user_in_level?
  # end

  # def close
  #   true
  # end

  # def approve
  #   invoice.processing? && user_in_level?
  # end

  # def remind
  #   true
  # end

  # def retract
  #   invoice.processing? && document_owner?
  # end

  # def remind_approver
  #   true
  # end

  # def void
  #   true 
  # end

  # def save_btn
  #   document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
  # end

  # def save_and_submit
  #   document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
  # end

  # def delete
  #   document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)
  # end

  # def more_actions
  #   true
  # end

  # def make_payment
  #   if invoice.approved? || invoice.auto_approved? || invoice.unpaid? || invoice.partially_paid? || invoice.paid?
  #     (user_in_level? && user.vendor_payment_creditor?) || user.vendor_payment_creditor?
  #   end
  # end

  # def audit_trail
  #   true
  # end

  # def download
  #   true
  # end

  # def send_btn
  #   true
  # end

  # def export_po_items
  #   true
  # end

  # def update_btn
  #   (document_owner? && (invoice.open? || invoice.retracted? || invoice.rejected?)) || 
  #   (invoice.processing? && user_in_level?)
  # end

  # def user_in_level?
  #   level = invoice.level
  #   amount = invoice.net_amount.value rescue 0
  #   level.present? ? level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
  # end

  # def document_owner?
  #   invoice.created_by_user_id.eql? user.id
  # end

  def all_delivered?
    e = inward_document.items.map {|i| i.delivered == i.quantity}
    (e.uniq.size == 1) && e.include?(true)
  end

  def all_accepted?
    if user.company.feature_subscription.grn_enabled
      e = inward_document.items.map {|i| i.accepted == i.quantity}
    elsif user.company.feature_subscription.srn_enabled
      e = inward_document.items.map {|i| i.order_amount.to_f == i.previously_billed_amount}
    elsif user.company.feature_subscription.grn_enabled && user.company.feature_subscription.srn_enabled
      e = inward_document.items.map {|i| i.accepted == i.quantity}
      e += inward_document.items.map {|i| i.order_amount.to_f == i.previously_billed_amount}
    end
    (e.uniq.size == 1) && e.include?(true)
  end


end