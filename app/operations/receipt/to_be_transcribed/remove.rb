class Receipt::ToBeTranscribed::Remove < Receipt::Base

  attr_accessor :receipt

  def pre_validate

  end

  def init
    id = params[:id] || params[:user_id]
    self.receipt = user.receipts.find_by(id: id)
  end

  def process
    unless receipt.update(to_be_transcribed: false)
      add_message :error, receipt.errors.full_messages
    end
  end

  def post_process
    add_message :success, "This receipt will not be transcribed"
  end
end