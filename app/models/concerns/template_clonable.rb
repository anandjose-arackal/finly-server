module TemplateClonable
  extend ActiveSupport::Concern

  def template_reference
    @template_reference ||= {}
  end

end