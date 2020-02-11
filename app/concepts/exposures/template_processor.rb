module Exposures::TemplateProcessor
  extend ActiveSupport::Concern

  def self.template(exposure, text, key: :record)
    LiquidHelper.interpolate(text, "#{key}" => exposure)
  end

  class_methods do
    def template(exposure, text, key: :record)
      Exposures::TemplateProcessor.template exposure, text, key: key
    end
  end

  def template(text, key: :record)
    self.class.template(self, text, key: key)
  end

end
