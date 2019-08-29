class LiquidHelper

  def self.interpolate(template, options)
    case template
    when String
      Liquid::Template.parse(template).render(options)
    when ActiveSupport::HashWithIndifferentAccess, Hash
      template.each_with_object(ActiveSupport::HashWithIndifferentAccess.new) {|(key, value), memo|
        memo[key] = interpolate(value, options)
      }
    when Array
      template.map {|value| interpolate(value, options)}
    else
      template
    end
  end

end