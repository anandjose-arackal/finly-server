module Exposures::Model::Exposable

  def to_exposure
    Object.const_get("#{self.class.name}Exposure")&.new(self)
  end

end