module ActiveRecordMaster

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def resolver(key = :default, klass)
      resolvers[key] = klass
    end

    def resolvers
      @resolvers ||= {}
    end

    def policy(policy = NoObject)
      @policy = policy unless policy == NoObject
      @policy
    end

    def system_events(*system_events)
      @system_events = system_events if system_events.present?
      @system_events ||= []
    end

    def request_events(*request_events)
      @request_events = request_events if request_events.present?
      @request_events ||= []
    end

    def all_events
      @system_events + @request_events
    end

    def event_workflow(workflow_klass)
      event_workflows << workflow_klass
    end

    def event_workflows
      @event_workflows ||= []
    end

    def form(form = NoObject)
      @form = form unless form == NoObject
      @form
    end

    def state_machine(state_machine = NoObject)
      @state_machine = state_machine unless state_machine == NoObject
      @state_machine
    end

    def create(create = NoObject)
      @create = create unless create == NoObject
      @create
    end

    def update(update = NoObject)
      @update = update unless update == NoObject
      @update
    end

    def resolve(user, scope = :default)
      scopes[scope]&.new(user, document)&.resolve
    end

    def representers
      @representers ||= {}
    end
    
    def representer(scope = :default, klass)
      @representers[scope] = klass
    end
  end

  def render(representer_scope = :default, representer: nil)
    renderer = representer || self.class.representers[representer_scope]
    if renderer.blank?
      raise "Renderer #{representer_scope} is not defined for #{self.name}"
    end
    renderer.new(self).to_json
  end
end