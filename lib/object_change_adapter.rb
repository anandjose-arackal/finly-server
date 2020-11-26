class ObjectChangeAdapter
  def init
  end


  def diff(changes={})
    changes.except!(:created_at, :updated_at, :id)
  end

end