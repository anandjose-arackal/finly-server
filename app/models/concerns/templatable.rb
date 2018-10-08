module Templatable
  extend ActiveSupport::Concern

  included do
    scope :templates, -> {where(is_template: true)}
    scope :exclude_templates, -> {where(is_template: [false, nil])}

    validate :valid_template

    class_attribute :attributes_to_merge
  end

  module ClassMethods

    def template_merge(*list)
      self.attributes_to_merge = list
    end

    def template_config(&block)
      amoeba(&block)
    end

    def templatable?
      true
    end

  end

  def templatable?
    true
  end

  def valid_template
    if is_template and template_name.blank?
      errors.add :template, 'name cannot be blank'
    end
  end

end