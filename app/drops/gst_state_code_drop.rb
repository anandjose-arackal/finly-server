class GstStateCodeDrop < Drop

  def code
    @object.state_code
  end

  def name
    @object.name
  end

end