class HashUtils

  def self.nested_search(obj,key)
    if obj.respond_to?(:key?) && obj.key?(key)
      obj[key]
    elsif obj.respond_to?(:each)
      r = nil
      obj.find{ |*a| r=nested_search(a.last,key) }
      r
    end
  end


end