class LiquidHelper

  def self.interpolate(template, options, args = {})
    case template
    when String
      Liquid::Template.parse(template).render(options, args)
    when ActiveSupport::HashWithIndifferentAccess, Hash
      template.each_with_object(ActiveSupport::HashWithIndifferentAccess.new) {|(key, value), memo|
        memo[key] = interpolate(value, options, args)
      }
    when Array
      template.map {|value| interpolate(value, options, args)}
    else
      template
    end
  end

end