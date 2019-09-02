class Documents::Master

  STORE = {}

  def self.for(document)
    Documents::Master::STORE[document.to_s]
  end

  def self.list
    Documents::Master::STORE.keys
  end

  def self.document(document = NoObject)
    unless document == NoObject
      @document = document
      Documents::Master::STORE[document.name] = self
    end
    @document
  end

  def self.scope(key = :default, klass)
    scopes[key] = klass
  end

  def self.scopes
    @scopes ||= {}
  end

  def self.policy(policy = NoObject)
    @policy = policy unless policy == NoObject
    @policy
  end

  def self.system_events(*system_events)
    @system_events = system_events if system_events.present?
    @system_events ||= []
  end

  def self.request_events(*request_events)
    @request_events = request_events if request_events.present?
    @request_events ||= []
  end

  def self.all_events
    @system_events + @request_events
  end

  def self.event_workflow(workflow_klass)
    event_workflows << workflow_klass
  end

  def self.event_workflows
    @event_workflows ||= []
  end

  def self.form(form = NoObject)
    @form = form unless form == NoObject
    @form
  end

  def self.state_machine(state_machine = NoObject)
    @state_machine = state_machine unless state_machine == NoObject
    @state_machine
  end

  def self.create(create = NoObject)
    @create = create unless create == NoObject
    @create
  end

  def self.update(update = NoObject)
    @update = update unless update == NoObject
    @update
  end

  def self.resolve(user, scope=:default)
    scopes[scope]&.new(user, document)&.resolve
  end

end