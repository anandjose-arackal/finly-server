module RuleBook::Page

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    # Alias method for register_master
    def book(klass)
      self.register_master klass
    end

    def rule(description, options = {}, &block)
      on = options[:on]
      unless on.present?
        raise "Event not defined for rule #{description} in class #{self.name}"
      end
      if on.respond_to?(:each)
        on.each do |event|
          register_rule(event, description, block)
        end
      else
        register_rule(on, description, block)
      end
    end

    def register_rule(event, description, block)
      rule = {description: description, block: block, event: event}
      self.register_multiple event, rule
      self.register_multiple :rules, rule
    end
  end

end