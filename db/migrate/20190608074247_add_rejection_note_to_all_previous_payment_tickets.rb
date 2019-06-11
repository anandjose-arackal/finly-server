class AddRejectionNoteToAllPreviousPaymentTickets < ActiveRecord::Migration[5.2]
  def change
    BankPaymentRequest.where(status_id: BankPaymentRequestStatus.id_for(:rejected)).each do |bpr|
      reject_trail = bpr.trails.where(action_id: TrailAction.id_for(:reject)).reorder(created_at: :desc).first
      rejection_note = reject_trail.note
      bpr.update(rejection_note: rejection_note)
    end
  end
end
