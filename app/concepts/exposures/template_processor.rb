module Exposures::TemplateProcessor
  extend ActiveSupport::Concern

  def self.template(exposure, text, key: :record, registers: {})
    LiquidHelper.interpolate(text, { "#{key}" => exposure }, { registers: registers&.with_indifferent_access })
  end

  class_methods do
    def template(exposure, text, key: :record, registers: {})
      Exposures::TemplateProcessor.template exposure, text, key: key, registers: registers
    end
  end

  def template(text, key: :record, registers: {})
    self.class.template(self, text, key: key, registers: registers)
  end

end
