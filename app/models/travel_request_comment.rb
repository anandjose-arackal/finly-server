# == Schema Information
#
# Table name: travel_request_comments
#
#  id                       :integer          not null, primary key
#  travel_request_id        :integer
#  content                  :text(65535)
#  user_id                  :integer
#  note                     :text(65535)
#  previous_value           :text(65535)
#  new_value                :text(65535)
#  edited_field             :text(65535)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  action_id                :integer
#  booking_id               :integer
#  booking_request_id       :integer
#  is_deleted               :boolean          default(FALSE)
#  delegated_action_user_id :integer
#

class TravelRequestComment < ApplicationRecord
  include SoftDeletable

  belongs_to :travel_request, optional: true
  belongs_to :user, optional: true
  belongs_to :action, optional: true, class_name: "TravelRequestCommentAction"
  belongs_to :booking, optional: true
  belongs_to :booking_request, optional: true
  belongs_to :delegated_action_user, optional: true, class_name: 'User'

  default_scope { order created_at: :desc }

  def retrieve_content(user)
    comment_content = ""

    if user.id == self.user_id
      comment_content += "You have"
    else
      comment_content += "#{self.user&.name} has"
    end
    if self.delegated_action_user_id.present?
      current_user_name = self.user.name
      comment_content = "#{self.delegated_action_user&.name} has"
    end

    case self.action_id
    when TravelRequestCommentAction.id_for(:comment)
      return "#{self.user&.name} commented: #{self.content}"
    when TravelRequestCommentAction.id_for(:submit)
      comment_content += " submitted the Travel Request"
    when TravelRequestCommentAction.id_for(:approve)
      comment_content += " approved the Travel Request"
    when TravelRequestCommentAction.id_for(:retract)
      comment_content += " retracted the Travel Request"
    when TravelRequestCommentAction.id_for(:reject)
      comment_content += " rejected the Travel Request"
    when TravelRequestCommentAction.id_for(:auto_approve)
      comment_content = "Payment Order has been auto approved as there is no reviewer assigned"
    when TravelRequestCommentAction.id_for(:unapprove)
      comment_content += " unapproved the Travel Request"
    when TravelRequestCommentAction.id_for(:take_control)
      comment_content += " taken control of the Travel Request"
    when TravelRequestCommentAction.id_for(:return_control)
      comment_content += " returned control of the Travel Request"
    when TravelRequestCommentAction.id_for(:add_booking)
      comment_content += " added a booking"
    when TravelRequestCommentAction.id_for(:remove_booking)
      comment_content += " removed a booking"
    when TravelRequestCommentAction.id_for(:reject_booking_request)
      comment_content += " rejected a booking request"
    when TravelRequestCommentAction.id_for(:selection_requested)
      comment_content += " requested selection  of booking options"
    when TravelRequestCommentAction.id_for(:selection_confirmed)
      comment_content += " confirmed selection"
    when TravelRequestCommentAction.id_for(:selection_approved)
      comment_content += " approved selection"
    when TravelRequestCommentAction.id_for(:created_by_delegate)
      comment_content += " created trip on behalf of #{current_user_name}"
    when TravelRequestCommentAction.id_for(:updated_by_delegate)
      comment_content += " updated trip on behalf of #{current_user_name}"
    when TravelRequestCommentAction.id_for(:submitted_by_delegate)
      comment_content += " submitted trip on behalf of #{current_user_name}"
    when TravelRequestCommentAction.id_for(:retracted_by_delegate)
      comment_content += " retracted trip on behalf of #{current_user_name}"
    else
      return nil
    end

    if self.note.present?
      comment_content += " with a note: #{self.note}"
    end

    comment_content
  end
end
