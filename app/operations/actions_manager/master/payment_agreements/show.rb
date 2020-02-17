class ActionsManager::Master::PaymentAgreements::Show < ActionsManager::Master::Base

  register_handle :payment_agreement_show
  register_actions [:edit_btn, :submit, :retract, :reject, :approve, :unapprove, :take_control, :return_control, :delete, :policy_editable, :terminate, :revise]

  def initialize(user=nil, params=nil)
    super
    result = ::PaymentAgreements::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.payment_agreement = result.payment_agreement
  end


  def edit_btn
    return false if payment_agreement.terminated? || payment_agreement.revised?

    # if user.vendor_payments_admin? && !user.is_payment_agreement_initiator?  && ( payment_agreement.retracted? || payment_agreement.rejected? || payment_agreement.awaiting_approval? )
    if user.vendor_payments_admin? && !user.is_payment_agreement_initiator? && (payment_agreement.awaiting_approval?)
      return true if payment_agreement.action_users(:return_control).include?(user)
    end

     # If PR initiator OR (admin+ PR initiator)
    if user.is_payment_agreement_initiator? && user.vendor_payments_admin? 
      if payment_agreement.draft? || payment_agreement.rejected? || payment_agreement.retracted?
        return true
      end 
    end

    if user.is_payment_agreement_initiator? && document_owner?
      if payment_agreement.draft? || payment_agreement.rejected? || payment_agreement.retracted? # || payment_agreement.revised?
        return true
      end 
    end

    if payment_agreement.is_reviewing_user?
      return payment_agreement.action_users(:approve).include?(user)
    end
    if user.is_payment_agreement_initiator? && user.vendor_payments_admin?
      if payment_agreement.awaiting_approval?
        return payment_agreement.action_users(:return_control).include?(user)
      end  
    end
  end

  def submit
    if user.is_payment_agreement_initiator? || user.vendor_payments_admin?
      if document_owner? && (payment_agreement.draft? || payment_agreement.retracted? || payment_agreement.rejected?)
        return true
      end
    end
  end

  def retract
    if document_owner?
      if payment_agreement.awaiting_approval? && !payment_agreement.closed?
        return true
      end
    end
  end

  def reject
    if payment_agreement.is_reviewing_user? || user.vendor_payments_admin?
      if payment_agreement.awaiting_approval? && user_in_level?
        return true
      end
    end
  end

  def approve
    return false if payment_agreement.terminated?
    # ############# Reviewer logic start #########################
    # if payment_agreement.is_reviewing_user? || user.vendor_payments_admin?
    #   if payment_agreement.awaiting_approval?
    #     last_trail = payment_agreement.trails.where.not(action_id: TrailAction.id_for(:update)).last rescue nil
    #     if (payment_agreement.get_reviewers.include?(user))
    #       if payment_agreement.action_users(:approve).include?(user)
    #         if (last_trail.action_id == TrailAction.id_for(:unapprove)) && (last_trail.action_user_id == user.id)
    #           return true
    #         end
    #         if last_trail.action_id == TrailAction.id_for(:approve)
    #           return true
    #         end
    #         if last_trail.action_id == TrailAction.id_for(:take_control)
    #           return true
    #         end
    #         if last_trail.action_id == TrailAction.id_for(:submit)
    #           return true
    #         end
    #       end
    #     end
    #   end
    # end
    # ############# Reviewer logic end #########################
    if payment_agreement.is_reviewing_user? || user.vendor_payments_admin?
      payment_agreement.get_reviewers.include?(user) && PaymentAgreement.status_ids(:awaiting_approval).include?(payment_agreement.status_id)
    end
  end

  def unapprove
    unless payment_agreement.approved? || payment_agreement.terminated?
      if last_level?
        state = (previous_reviewer.include? user.id) ? true : false
      else
        previous_reviewer.include? user.id
      end
    end
  end

  def take_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if (payment_agreement.awaiting_approval? && payment_agreement.get_reviewers.exclude?(user))
        return true
      end
      if payment_agreement.awaiting_approval? && !payment_agreement.action_users(:return_control).include?(user) && !payment_agreement.action_users(:approve).include?(user)
        return true
      end
    end
    ############# Admin logic end #################### 
  end

  def return_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if payment_agreement.awaiting_approval?
        return true if payment_agreement.action_users(:return_control).include?(user)
      end
    end
    ############# Admin logic end ####################
  end


  def document_owner?
    payment_agreement.creator_id.eql?(user.id)
  end

  def user_in_level?
    payment_agreement.get_reviewers.include?(user)
  end

  def final_reviewers
    r_ids = payment_agreement.get_reviewal_chain.last[:reviewers].pluck(:id)
  end

  def last_level?
    if payment_agreement.awaiting_approval?
      payment_agreement.get_reviewal_chain&.last[:level_number] == payment_agreement.level&.level_number
    end
  end

  def previous_reviewer
    payment_agreement.get_reviewers('previous').pluck(:id)
  end

  def user_can_take_control?
    (payment_agreement.dlrms&.find_by(level_id: payment_agreement.level&.id).taken_control_by_id != user.id)
  end

  def user_can_return_control?
    payment_agreement.dlrms&.find_by(level_id: payment_agreement.level&.id).taken_control &&
    payment_agreement.dlrms&.find_by(level_id: payment_agreement.level&.id).taken_control_by_id == user.id
  end

  def delete
    (payment_agreement.draft? || payment_agreement.retracted? || payment_agreement.rejected?) && (document_owner?)
  end

  def policy_editable
    payment_agreement.draft? || payment_agreement.retracted? || payment_agreement.rejected?
  end

  def terminate
    user.vendor_payments_admin? && (payment_agreement.approved? || payment_agreement.auto_approved?)
  end

  def revise
    (user.vendor_payments_admin? || document_owner?) && (payment_agreement.approved? || payment_agreement.auto_approved?) && actual_invoice_absent
  end

  def actual_invoice_absent
    self.payment_agreement.agreement_invoices.blank? && self.payment_agreement.recurring_invoices.blank?
  end

end