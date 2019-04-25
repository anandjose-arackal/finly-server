# == Schema Information
#
# Table name: trail_actions
#
#  id   :integer          not null, primary key
#  name :string(255)
#

class TrailAction < ApplicationRecord
  include Seedable
  def self.values
    [
        :create,
        :update,
        :retract,
        :submit,
        :approve,
        :approve_and_forward,
        :auto_approve,
        :void,
        :reject,
        :unapprove,
        :take_control,
        :return_control,
        :credited,
        :settled,
        :settlement_confirmed,
        :reimbursed,
        :reimbursement_confirmed,
        :closed, # keeping this for historical purpose
        :close,
        :downloaded,
        :revision,
        :hold,
        :release,
        # Bank Payment Request
        :mark_as_credited,
        :credit,
        :send_to_vendor,
        :reopen,

        # TravelRequestBookingActions
        :confirm_selection,
        :approve_selection,
        :reject_selection,
        :unapprove_selection,
        :confirm_booking,
        :reject_booking_request,
        :request_selection,
        :retract_booking,
        :forward
    ]
  end
end