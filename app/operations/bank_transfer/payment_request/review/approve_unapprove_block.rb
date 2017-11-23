# this class takes a bank payment request id and returns the ids of BankPaymentRequestTrails that need to be excluded
# for the approval flow chart. These ids will then be used to extract the trails for that particular object
class BankTransfer::PaymentRequest::Review::ApproveUnapproveBlock < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_request, :trails, :response

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankPaymentRequest.find_by(id: id)
    self.trails = self.bank_payment_request.bank_payment_request_trails
  end

  def validate
    if bank_payment_request.blank?
      add_message :error, "Payment order not found"
    end
  end

  def process
    action_user_ids = bank_payment_request.bank_payment_request_trails.pluck(:action_user_id)
    id_ranges = []
    action_user_ids.each do |user_id|
      [UserRole.id_for(:manager), UserRole.id_for(:finance), UserRole.id_for(:admin)].each do |role|
        approve_action = self.trails.where(action_user_role_id: role, action_id: BankPaymentRequestTrailAction.id_for(:approve)).reorder(created_at: :asc).first
        unapprove_action = self.trails.where(action_user_role_id: role, action_id: BankPaymentRequestTrailAction.id_for(:unapprove)).reorder(created_at: :asc).first
        if approve_action.present? && unapprove_action.present?
          id_ranges << approve_action.id..unapprove_action.id
        end
      end
    end

    # once we have the respective id ranges, now we can remove the respective records
    spurious_id_ranges = []
    id_ranges.each do |range|
      range_array = range.to_a
      if range_array.subset?(spurious_id_ranges)
        next
      end
      spurious_id_ranges += range_array
    end

    self.response = self.trails.where.not(id: spurious_id_ranges)
  end

  def post_process

  end


end