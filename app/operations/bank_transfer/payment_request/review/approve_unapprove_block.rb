# this class takes a bank payment request id and returns the ids of BankPaymentRequestTrails that need to be excluded
# for the approval flow chart. These ids will then be used to extract the trails for that particular object
class BankTransfer::PaymentRequest::Review::ApproveUnapproveBlock < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_request, :trails, :response, :approve_id, :unapprove_id

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankPaymentRequest.find_by(id: id)
    self.trails = self.bank_payment_request.bank_payment_request_trails.trails_for_approval_chain
    self.approve_id = BankPaymentRequestTrailAction.id_for(:approve)
    self.unapprove_id = BankPaymentRequestTrailAction.id_for(:unapprove)
  end

  def validate
    if bank_payment_request.blank?
      add_message :error, "Payment order not found"
    end
  end

  def process
    action_user_ids = self.trails.pluck(:action_user_id).uniq!
    id_ranges = []
    action_user_ids.each do |user_id|
      [UserRole.id_for(:manager), UserRole.id_for(:finance), UserRole.id_for(:admin)].each do |role|
        approve_action = self.trails.where.not(id: id_ranges).with_action_user_and_role(user_id, role, approve_id).reorder(created_at: :asc).first
        unapprove_action = self.trails.where.not(id: id_ranges).with_action_user_and_role(user_id, role, unapprove_id).reorder(created_at: :asc).last
        if approve_action.present? && unapprove_action.present?
          id_ranges += (approve_action.id..unapprove_action.id).to_a
        end
      end
    end

    # once we have the respective id ranges, now we can remove the respective records
    spurious_id_ranges = id_ranges.uniq

    self.response = self.trails.where.not(id: spurious_id_ranges)
  end

  def post_process

  end

  def success
    self.response
  end


end