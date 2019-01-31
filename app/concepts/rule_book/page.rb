module RuleBook::Page

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def index(klass = NoObject)
      unless klass == NoObject
        self.register_master klass
      end
      master
    end

    def rule(description, options = {}, &block)
      on = options[:on]
      unless on.present?
        raise "Event not defined for rule #{description} in class #{self.name}"
      end
      if on.respond_to?(:each)
        on.each do |event|
          register_rule(event, description, block, options)
        end
      else
        register_rule(on, description, block, options)
      end
    end

    def register_rule(event, description, block, options)
      rule = RuleBook::Rule.new(
          {
              description: description,
              block: block,
              event: event,
              options: options,
              page: self
          }
      )
      self.register_multiple event, rule
      self.register_multiple :rules, rule
    end
  end

end