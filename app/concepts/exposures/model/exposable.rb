module Exposures::Model::Exposable
  extend ActiveSupport::Concern

  class_methods do
    def to_exposures
      Exposures::LazyList.(self)
    end

    def exposure_class
      Object.const_get("#{self}Exposure") rescue nil
    end
  end

  def to_exposure
    Object.const_get("#{self.class.name}Exposure")&.new(self)
  end

end