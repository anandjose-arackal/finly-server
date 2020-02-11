module Exposures::TemplateProcessor
  extend ActiveSupport::Concern

  def self.template(exposure, text, key: :record)
    LiquidHelper.interpolate(text, "#{key}" => exposure)
  end

  class_methods do
    def template(text, key: :record)
      Exposures::TemplateProcessor.template self, text, key: key
    end
  end

end
