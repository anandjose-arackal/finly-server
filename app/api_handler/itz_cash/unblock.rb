class ItzCash::Unblock < ItzCash::Block

  def operation_type
    Constants::ItzCash::OPERATION_TYPE_UNBLOCK
  end

end