class ActionsManager::Master::Procurements::PurchaseRequests::Show < ActionsManager::Master::Base

  register_handle :purchase_request_show
  register_actions [ :save_btn, :submit, :retract, :reject, :approve, :unapprove, :take_control, :delete_pr_line_item, :reject_pr_line_item, :return_control, :add_new_line_item ]

  def initialize(user=nil, params=nil)
    super
    result = ::Procurements::PurchaseRequests::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.purchase_request = result.purchase_request
  end

  def save_btn
    # If admin but not initiator, cannot save in draft stage
    if user.vendor_payments_admin? && !user.is_purchase_request_initiator?  && ( purchase_request.retracted? || purchase_request.rejected? || purchase_request.awaiting_approval? )
      return true
    end

     # If PR initiator OR (admin+ PR initiator)
    if user.is_purchase_request_initiator? && user.vendor_payments_admin? 
      if purchase_request.draft? || purchase_request.rejected? || purchase_request.retracted?
        return true
      end 
    end

    if user.is_purchase_request_initiator? 
      if purchase_request.draft? || purchase_request.rejected? || purchase_request.retracted?
        return true
      end 
    end
  end

  def submit
    if user.is_purchase_request_initiator? || user.vendor_payments_admin?
      if document_owner? && (purchase_request.draft? || purchase_request.retracted? || purchase_request.rejected?)
        return true
      end
    end
  end

  def retract
    if document_owner?
      if purchase_request.awaiting_approval? && !purchase_request.closed?
        return true
      end
    end
  end

  def reject
    if purchase_request.is_reviewing_user? || user.vendor_payments_admin?
      if purchase_request.awaiting_approval? && user_in_level?
        return true
      end
    end
  end

  def approve
    ############# Reviewer logic start #########################
    if purchase_request.is_reviewing_user? || user.vendor_payments_admin?
      if purchase_request.awaiting_approval?
        last_trail = purchase_request.trails.where.not(action_id: TrailAction.id_for(:update)).last rescue nil
        if (purchase_request.get_reviewers.include?(user))
          if purchase_request.action_users(:approve).include?(user)
            if (last_trail.action_id == TrailAction.id_for(:unapprove)) && (last_trail.action_user_id == user.id)
              return true
            end
            if last_trail.action_id == TrailAction.id_for(:approve)
              return true
            end
            if last_trail.action_id == TrailAction.id_for(:take_control)
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

  def unapprove
    unless purchase_request.approved?
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
      if (purchase_request.awaiting_approval? && purchase_request.get_reviewers.exclude?(user))
        return true
      end
      if purchase_request.awaiting_approval? && !purchase_request.action_users(:return_control).include?(user) && purchase_request.action_users(:approve).include?(user)
        return true
      end
    end
    ############# Admin logic end #################### 
  end

  def return_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if purchase_request.awaiting_approval?
        return true if purchase_request.action_users(:return_control).include?(user)
      end
    end
    ############# Admin logic end ####################
  end

  def delete_pr_line_item
    if purchase_request.purchase_request_status_id.blank? || purchase_request.draft? || purchase_request.rejected? || purchase_request.retracted?
      return true
    end
  end

  def reject_pr_line_item
    if user.vendor_payments_admin? || user.is_purchase_request_initiator?
      if purchase_request.awaiting_approval?
        return true
      end
    end
    if purchase_request.is_reviewing_user?
      if user_in_level?
        if purchase_request.awaiting_approval?
          return true
        end
      end
    end
  end

  def create_and_submit
  end

  def add_new_line_item
    # If admin but not initiator, cannot save in draft stage
    if user.vendor_payments_admin? && !user.is_purchase_request_initiator?  && ( purchase_request.retracted? || purchase_request.rejected? || purchase_request.awaiting_approval? )
      return true
    end

     # If PR initiator OR (admin+ PR initiator)
    if user.is_purchase_request_initiator? && user.vendor_payments_admin? 
      if purchase_request.draft? || purchase_request.rejected? || purchase_request.retracted?
        return true
      end 
    end

    if user.is_purchase_request_initiator?
      if purchase_request.draft? || purchase_request.rejected? || purchase_request.retracted?
        return true
      end 
    end
  end

  def document_owner?
    purchase_request.creator_id.eql?(user.id)
  end

  def user_in_level?
    purchase_request.get_reviewers.include?(user)
  end

  def final_reviewers
    r_ids = purchase_request.get_reviewal_chain.last[:reviewers].pluck(:id)
  end

  def last_level?
    if purchase_request.awaiting_approval?
      purchase_request.get_reviewal_chain&.last[:level_number] == purchase_request.level&.level_number
    end
  end

  def previous_reviewer
    purchase_request.get_reviewers('previous').pluck(:id)
  end

  def user_can_take_control?
    (purchase_request.dlrms&.find_by(level_id: purchase_request.level&.id).taken_control_by_id != user.id)
  end

  def user_can_return_control?
    purchase_request.dlrms&.find_by(level_id: purchase_request.level&.id).taken_control &&
    purchase_request.dlrms&.find_by(level_id: purchase_request.level&.id).taken_control_by_id == user.id
  end


end