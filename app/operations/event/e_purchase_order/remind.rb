class Event::EPurchaseOrder::Remind < Event::EPurchaseOrder::Base
  attr_accessor :approved, :auto_approve,
                :controlling_users

  def action_name
    'Purchase Order Approved'
  end

  def init
    super
    self.approved = (purchase_order.approved? || purchase_order.closed? || purchase_order.auto_approved?) if purchase_order.present?
    self.auto_approve = params[:auto_approve]

    self.controlling_users = []

    # Get controlling users
    level = self.purchase_order.level


    if level.present?
      amount = purchase_order.balance_amount&.value || 0

      # Find list of possible controlling user ids
      controlling_users_ids = level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id)

      user_selected_reviewer = purchase_order.document_level_reviewer_mappings.with_level_ids(level.id).last&.reviewer

      if user_selected_reviewer.present? && controlling_users_ids.include?(user_selected_reviewer.id)
        # Check if user selected reviewer is satisfies level reviewer mapping threshold criteria
        self.controlling_users.push user_selected_reviewer
      else
        # User selected reviewer is not present in list of users satisfying current level's threshold criteria
        # select all the threshold satifying reviewers
        user.company.users.with_id(controlling_users_ids).each do |user|
          self.controlling_users.push(user)
        end
      end
    else
      controlling_users = []
    end
  end

  # def event_id
    # NotifierType.id_for(:purchase_order_approve)
  # end

  def affected_users
    users = []
    if controlling_users.present?
      controlling_users.each do |user|
        users.push(user)
      end
    end
    users
  end

  def notification_affected_users
    []
  end

  def mailer_subject(user)
    "Reminder - Purchase order #{purchase_order.po_number} is awaiting your approval"
  end

  def mailer_body(user)
    "Purchase Order - '#{self.purchase_order.po_number}' is currently waiting for your approval"
  end
end
