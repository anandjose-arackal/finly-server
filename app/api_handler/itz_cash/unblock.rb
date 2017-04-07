class ItzCash::Unblock < ItzCash::Block

  def request_type
    Constants::ItzCash::OPERATION_TYPE_UNBLOCK
  end

  def post_process
    card.update_attribute(:active, true)
  end

end