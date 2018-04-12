# operation that creates a comment from the user's input for the timeline of a
# Bank Payment Request

class BankTransfer::PaymentRequest::Comment::Create < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_request, :request_comment_params

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id)
    # self.payment_request = BankPaymentRequest.find_by(id: id)
    self.request_comment_params = comment_params
  end

  def pre_process
    request_comment_params[:action_id] = BankPaymentRequestCommentAction.id_for(:comment)
    request_comment_params[:user_id] = user.id
  end

  def process
    comment = payment_request.comments.build(request_comment_params)
    unless comment.save
      add_message :error, comment.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Comment added!"

    Event::EBankPaymentRequest::EComment::Create.(user, bank_payment_request: self.payment_request)
  end

  private

  def comment_params
    params.require(:payment_request_comment).permit(:content)
  end
end
