class AuditTrail::ObjectChangeAdapter
  def init
  end


  def diff(changes={})
    changes = changes.reject{|k,v| v.first.to_s == v.last.to_s}
    changes.except!(:created_at, :updated_at, :id,"updated_at")
  end

end