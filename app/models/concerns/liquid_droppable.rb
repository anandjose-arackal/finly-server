module LiquidDroppable

  def to_liquid
    Object.const_get("#{self.class.name}Drop")&.new(self)
  end

end