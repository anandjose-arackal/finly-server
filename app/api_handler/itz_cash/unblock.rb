class ItzCash::Unblock < ItzCash::Block

  def request_type
    Constants::ItzCash::OPERATION_TYPE_UNBLOCK
  end

end