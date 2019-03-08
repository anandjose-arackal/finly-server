# this class takes a bank payment request id and returns the ids of BankPaymentRequestTrails that need to be excluded
# for the approval flow chart. These ids will then be used to extract the trails for that particular object
class BankTransfer::PaymentRequest::Review::ApproveUnapproveBlock < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_request, :trails, :response, :approve_id, :unapprove_id

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankPaymentRequest.find_by(id: id)
    self.trails = self.bank_payment_request.trails #.trails_for_approval_chain
    self.approve_id = BankPaymentRequestTrailAction.id_for(:approve)
    self.unapprove_id = BankPaymentRequestTrailAction.id_for(:unapprove)
  end

  def validate
    if bank_payment_request.blank?
      add_message :error, "Payment order not found"
    end
  end

  def process
    trail_a = []
    trail_h = {}
    admin_role_id = UserRole.id_for(:admin)
    self.trails.each do |trail|
      user_id = trail.action_user_id
      role_id = trail.action_user_role_id
      for_user_id = trail.action_for_user_id
      for_user_role_id = trail.action_for_user_role_id
      if trail_h[role_id].nil?
        trail_h[role_id] = {}
      end
      # All Admin Actions are considered
      # All actions taken for another user are consider ( Take Control )
      # ASSUMPTION: User does not appear twice in the review workflow with the same role
      # If a user appears twice in the approve workflow, then clear everything in the range
      if trail_h&.dig(role_id, user_id).present? and for_user_id.blank? and role_id != admin_role_id
        # trail has to be truncated as another action from the same user has taken place
        index = trail_a.find_index(trail_h&.dig(role_id, user_id))
        next if index.nil?
        trail_a = trail_a[0, index]
        # spurious_ids << trail_a[index, trail_a.size]
      end
      trail_a << trail
      trail_h[role_id][user_id] = trail
    end
    self.response = trail_a
  end

  # def process
  #   action_user_ids = self.trails.pluck(:action_user_id).uniq
  #   id_ranges = []
  #   action_user_ids.each do |user_id|
  #     [UserRole.id_for(:manager), UserRole.id_for(:finance), UserRole.id_for(:admin)].each do |role|
  #       approve_action = self.trails.where.not(id: id_ranges).with_action_user_and_role(user_id, role, approve_id).reorder(created_at: :asc).first
  #       if approve_action.blank?
  #         unapprove_action = nil
  #       else
  #         unapprove_action = self.trails.where.not(id: id_ranges).with_action_user_and_role(user_id, role, unapprove_id).reorder(created_at: :asc).last
  #       end
  #       if approve_action.present? && unapprove_action.present?
  #         id_ranges += (approve_action.id..unapprove_action.id).to_a
  #       end
  #     end
  #   end
  #
  #   # once we have the respective id ranges, now we can remove the respective records
  #   spurious_id_ranges = id_ranges.uniq
  #
  #   self.response = self.trails.where.not(id: spurious_id_ranges)
  # end

  def post_process

  end

  def success
    self.response
  end


end