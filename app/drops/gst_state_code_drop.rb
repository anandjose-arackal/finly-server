class GstStateCodeDrop < Drop

  def code
    record.state_code
  end

  def name
    record.name
  end

end