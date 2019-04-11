class ActionsManager::Master::Procurements::PurchaseOrderShow < ActionsManager::Master::Base

  register_handle :proc_purchase_order_show
  validate :input
  register_actions [:more_details_button, :send_mail, :export_items, :submit, :reject, :approve, :remind, :retract,
    :remind_approver, :void, :save_btn, :save_and_submit, :delete, :more_actions, :audit_trail, :download,
    :send_btn, :export_po_items, :update_btn, :mark_send_to_vendor, :po_revision, :close, :reopen, :unapprove,
    :take_control, :return_control, :forward
  ]

  def initialize(user = nil, params = {})
    super
    result = ::Procurements::PurchaseOrders::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.procurement = result.procurement
    self.purchase_order = result.purchase_order
  end

  def mark_send_to_vendor
    if purchase_order.is_initiating_user? || user.vendor_payments_admin?
      (purchase_order.approved? || purchase_order.auto_approved?) && (user_in_level? || document_owner? || user.vendor_payments_admin?)
    end
  end

  def po_revision
    # can only be done after the po status is set to "sent to vendor"
    # prevent revision if procurement has invoice or grn attached
    if po_modifiable?
      unless procurement.po_revisions.pluck(:revision_of_id).include?(purchase_order.id)
        (purchase_order.sent_to_vendor?) && (user_in_level? || document_owner? || user.vendor_payment_admin?)
      end
    end
  end

  def reopen
    unless procurement.po_revisions.pluck(:revision_of_id).include? purchase_order.id
      ((purchase_order.closed?) && (user_in_level? || document_owner? || user.vendor_payment_admin?)) # || (purchase_order.auto_approved? && user.vendor_payment_admin? )
    end
  end

  def more_details_button
    true
  end

  def send_mail
    if purchase_order.is_initiating_user? || user.vendor_payments_admin?
      (purchase_order.approved? || purchase_order.auto_approved?) && (user_in_level? || document_owner? || user.vendor_payments_admin?)
    end
  end

  def export_items
    true
  end

  def submit
    if user.is_purchase_order_initiator? || user.vendor_payments_admin?
      document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
    end
  end

  def reject
    if purchase_order.is_reviewing_user?
      purchase_order.processing? &&
          user_in_level?
    end
  end

  def close
    unless purchase_order.procurement.invoices.blank? && purchase_order.procurement.inward_documents.blank?
      (purchase_order.approved? || purchase_order.auto_approved? || purchase_order.sent_to_vendor?) && (user_in_level? || document_owner?)
    end

    # if user.vendor_payments_admin? || purchase_order.is_initiating_user? || purchase_order.is_reviewing_user?
  end

  def approve
    ############# Reviewer logic start #########################
    if purchase_order.is_reviewing_user? #|| user.vendor_payments_admin?
      if purchase_order.processing?
        last_trail = purchase_order.trails.where.not(action_id: TrailAction.id_for(:update)).last rescue nil
        if (purchase_order.get_reviewers.include?(user))
          if purchase_order.action_users(:approve).include?(user)
            if (last_trail.action_id == TrailAction.id_for(:unapprove)) && (last_trail.action_user_id == user.id)
              return true
            end
            if last_trail.action_id == TrailAction.id_for(:approve)
              return true
            end
            if last_trail.action_id == TrailAction.id_for(:submit)
              return true
            end
          end
        end
      end
    end
    ############# Reviewer logic end #########################
  end

  def remind
    return false unless procurement.po_revisions.pluck(:revision_of_id).include?(purchase_order.id)

    purchase_order.is_initiating_user? and purchase_order.processing?
  end

  def retract

    if (procurement.invoices.blank? && procurement.inward_documents.blank?) && document_owner?
      if purchase_order.processing?
        return true
      end
      if (purchase_order.approved? || purchase_order.auto_approved?) && (!purchase_order.sent_to_vendor? && !purchase_order.closed? && !purchase_order.voided?)
        return true
      end
    end

    # if purchase_order.is_initiating_user? || user.vendor_payments_admin?
    #   if (procurement.invoices.blank? && procurement.inward_documents.blank?) && !purchase_order.sent_to_vendor?
    #     purchase_order.processing? || purchase_order.approved? || purchase_order.auto_approved?
    #     document_owner?
    #   end

    # end
  end

  def remind_approver
    purchase_order.is_initiating_user? and purchase_order.processing? and document_owner?
  end

  def void
    # only po initiator or the admin can void the po)
    # and if the procurement has any document, they cant void
    (document_owner? || user.vendor_payments_admin?) && (PurchaseOrderStatus.status_ids_for_voidable.include?(purchase_order.purchase_order_status_id) && purchase_order.procurement.invoices.blank? && purchase_order.procurement.inward_documents.blank?)
  end

  def save_btn
    # admin can save provided it is open or processing or the provided condiftions
    # document owner can save provided po is open, retracted or rejected
    if po_modifiable?
      unless procurement.po_revisions.pluck(:revision_of_id).include? purchase_order.id
        # Admin
        (user.vendor_payment_admin? && (!purchase_order.voided? && !purchase_order.approved? && !purchase_order.closed? && !purchase_order.sent_to_vendor?) &&
            !((purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?))) ||
            # Doc owner
            (document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)) ||
            # Reviewer
            (purchase_order.processing? && user_in_level?)
      end
    end

    # user.vendor_payments_admin? || ( document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?) )
  end

  def save_and_submit
    # ( document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?) ) ||
    # (purchase_order.processing? && user_in_level?) ||
    # (user.vendor_payments_admin? && purchase_order.voided?)
    if user.is_purchase_order_initiator? #|| user.vendor_payments_admin?
      (document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)) # || user.vendor_payments_admin?
    end
  end

  def delete
    if user.is_purchase_order_initiator? || user.vendor_payments_admin?
      if document_owner? && (purchase_order.open? || purchase_order.retracted? || purchase_order.rejected?)
        return true
      end
    end

  end

  def more_actions
    true
  end

  def audit_trail
    true
  end

  def download
    (purchase_order.approved? || purchase_order.auto_approved?)
  end

  def send_btn
    if (purchase_order.approved? || purchase_order.auto_approved?)
      (user_in_level? || document_owner? || user.vendor_payments_admin?)
    end
  end

  def export_po_items
    true
  end

  def update_btn
    save_btn
  end

  def unapprove
    # if user_in_level? && last_level?
    #   state = (user_in_level? && (final_reviewers.include? user.id)) ? false : true
    # end

    # if user_in_level?
    #   state = (last_level? && (final_reviewers.include? user.id)) ? false : true
    # else
    #   previous_reviewer.include? user.id
    # end

    # if user_in_level?
    #   if previous_reviewer.include? user.id
    #     state = true
    #   end
    # end

    unless purchase_order.approved?
      if last_level?
        state = (previous_reviewer.include? user.id) ? true : false
      else
        previous_reviewer.include? user.id
      end
    end

  end

  # def take_control
  #   if user.vendor_payment_admin? && purchase_order.processing? && user_can_take_control?
  #     true
  #   end
  # end

  # def return_control
  #   if user.vendor_payment_admin? && purchase_order.processing? && user_can_return_control?
  #     true
  #   end
  # end

  def take_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if (purchase_order.processing? && purchase_order.get_reviewers.exclude?(user))
        return true
      end
      if purchase_order.processing? && !purchase_order.action_users(:return_control).include?(user) && purchase_order.action_users(:approve).include?(user)
        return true
      end
    end
    ############# Admin logic end ####################    
  end

  def return_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if purchase_order.processing?
        return true if purchase_order.action_users(:return_control).include?(user)
      end
    end
    ############# Admin logic end ####################
  end

  def po_modifiable?
    (procurement.invoices.blank? && procurement.inward_documents.blank?)
  end

  def document_owner?
    purchase_order.user_id.eql?(user.id)
  end

  def user_in_level?
    # level = purchase_order.level
    # amount = purchase_order.balance_amount.value rescue 0
    # level.present? ? level.level_reviewer_mappings.non_deleted.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
    purchase_order.get_reviewers.include?(user)
  end


  def final_reviewers
    r_ids = purchase_order.get_reviewal_chain.last[:reviewers].pluck(:id)
  end

  def last_level?
    if purchase_order.processing?
      purchase_order.get_reviewal_chain&.last[:level_number] == purchase_order.level&.level_number
    end
  end

  def previous_reviewer
    purchase_order.get_reviewers('previous').pluck(:id)
  end

  def user_can_take_control?
    # check for the current level if it isn't taken control
    # check if the same user is not taking control twice
    # check if for the same level if any other user has also taken control
    (purchase_order.dlrms&.find_by(level_id: purchase_order.level&.id).taken_control_by_id != user.id)
  end

  def user_can_return_control?
    purchase_order.dlrms&.find_by(level_id: purchase_order.level&.id).taken_control &&
    purchase_order.dlrms&.find_by(level_id: purchase_order.level&.id).taken_control_by_id == user.id
  end

  # def unapprove
  #   ############# Reviewer logic start ######################
  #   if purchase_order.action_users(:unapprove).include?(user) || user.vendor_payments_admin?
  #     last_trail = purchase_order.trails.last rescue nil
  #     if purchase_order.processing? && (last_trail.action_id == TrailAction.id_for(:approve)) &&
  #         (last_trail.action_user_id == user.id)
  #       return true
  #     end
  #   end
  #   ############# Reviewer logic end #########################
  # end

  def forward
    purchase_order.processing? && purchase_order.get_reviewers.include?(user)
  end

end
