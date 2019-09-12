class TdsRateListDrop < Drop

  def name
    @object.name
  end

  def rate
    @object.tds
  end

  def gl_code
    @object.gl_code
  end

end