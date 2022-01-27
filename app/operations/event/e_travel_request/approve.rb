class Event::ETravelRequest::Approve < Event::ETravelRequest::Base

  attr_accessor :approved, :approving_user, :auto_approve

  def action_name
    "Trip Approved"
  end

  def init
    super
    self.approving_user = self.travel_request.trails.last.action_user rescue nil
    self.approved = travel_request.approved? if travel_request.present?
    self.auto_approve = params[:auto_approve]
  end

  def validate
    super
    unless self.approving_user.present? or auto_approve
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:travel_request_approve)
  end

  def affected_users
    # last_tr_trail = self.travel_request.travel_request_trails.order(:created_at).last rescue nil
    # if approved
    #   if auto_approve
    #     [self.travel_request.user]
    #   else
    #     [last_tr_trail.action_user, self.travel_request.user]
    #   end
    # else
    #   [last_tr_trail.action_user, self.travel_request.controlling_user]
    # end
   self.travel_request.document_role_users(:travel_manager).present? ? ( self.travel_request.affected_users(:approve) + self.travel_request.document_role_users(:travel_manager) ) :  self.travel_request.affected_users(:approve)
  end

  def mailer_subject(user)
    approver_id = self.travel_request.trails&.last&.action_user_id
    if approver_id.present? and (user.id == approver_id)
      "Trip Approved : #{self.travel_request.trip_id}"
    else
      if approved 
        if (user.id == self.travel_request.user.id)
          if auto_approve
            message = "Congratulations! Your trip #{travel_request.trip_id} has been auto approved"
          else
            message = "Congratulations! Your trip #{travel_request.trip_id} has been has been approved"
          end
        elsif self.travel_request.document_role_users(:travel_manager).include?(user)
          "#{self.approving_user.name&.titleize} has approved the trip: #{travel_request.trip_id} and is currently waiting for your approval"
        else
          "#{self.approving_user.name&.titleize} has approved the trip: #{travel_request.trip_id}"
        end
      elsif self.travel_request.document_role_users(:travel_manager).include?(user)
          "#{self.approving_user.name&.titleize} has approved the trip: #{travel_request.trip_id} and is currently waiting for your approval"
      end
    end
  end

  def mailer_body(user)
    # approver_id = self.travel_request.trails.last.action_user.id rescue nil
    approver_id = self.travel_request.trails.last.action_user.id rescue nil
    if approver_id.present? and (user.id == approver_id)
      message = "You have successfully approved the trip : #{self.travel_request.trip_id}"
    else
      if approved
        if (user.id == travel_request.user.id)
          if auto_approve
            message = "Congratulations! Your trip has been auto-approved"
          else
            message = "Congratulations! Your trip has been approved"
          end
        elsif self.travel_request.document_role_users(:travel_manager).include?(user)
          message = "#{self.approving_user.name&.titleize} has approved the trip '#{self.travel_request.trip_id}' and is currently waiting for your approval"
        else
          "#{self.approving_user.name&.titleize} has approved the trip: #{travel_request.trip_id}"
        end
      elsif self.travel_request.document_role_users(:travel_manager).include?(user)
          message = "#{self.approving_user.name&.titleize} has approved the trip '#{self.travel_request.trip_id}' and is currently waiting for your approval"
      end
    end
    message
  end

  def travel_request_view_role(user)
    # Submission of trip is done by employee himself
    # if user.id == travel_request.user_id
    #   return UserRole.id_for(:employee)
    # elsif user.id == travel_request.controlling_user_id
    #   return travel_request.controlling_user_role_id
    # elsif user.id == self.travel_request.travel_request_trails.last.action_user_id
    #   return self.travel_request.travel_request_trails.last.action_user_role_id
    # end
    if user.id == travel_request.user_id
      return UserRole.id_for(:employee)
    # elsif user.id == travel_request.controlling_user_id
    elsif self.travel_request.document_role_users(:travel_manager).include?(user)
      return UserRole.id_for(:travel_manager)
    elsif travel_request.get_reviewers.include?(user)
      return UserRole.id_for(:manager)
    end
  end

end