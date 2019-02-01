module RuleBook::Page

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def rule_book_page_setup
      include EventBus::Subscriber
    end

    def index(klass = NoObject)
      unless klass == NoObject
        # Event::Subscriber function
        self.bus klass
      end
      bus
    end

    def rule(description, options = {}, &block)
      on = options[:on]
      unless on.present?
        raise "Event not defined for rule #{description} in class #{self.name}"
      end
      if on.respond_to?(:each)
        on.each do |event|
          subscribe_rule(event, description, block, options)
        end
      else
        subscribe_rule(on, description, block, options)
      end
    end

    def subscribe_rule(event, description, block, options)
      rule = RuleBook::Rule.new(
          {
              description: description,
              block: block,
              event: event,
              options: options,
              page: self
          }
      )
      # Event::Subscriber function
      self.subscribe(event, rule)
    end
  end

end