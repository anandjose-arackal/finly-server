class Receipt::Transcription::Enable < Receipt::Transcription::Disable


  def process
    unless receipt.update(to_be_transcribed: true)
      add_message :error, receipt.errors.full_messages
    end
  end

  def post_process
    add_message :success, "This message will be auto-converted to an expense"
  end

end