class Routers::Base
  include DynamicAttributes
  extend Dry::Monads[:result]

  class_attr :use_route, default: Routers::Route

  def self.allow_multiple_associations!
    @allow_multiple_associations = true
  end

  def self.allow_multiple_associations?
    @allow_multiple_associations || false
  end

  def self.draw(&block)
    instance_exec &block
  end

  def self.scope(key, &block)
    scopes.push key
    instance_exec &block
    scopes.pop
  end

  def self.with_options(options, &block)
    global_options.push options
    instance_exec &block
    global_options.pop
  end

  def self.routes
    map.keys
  end

  def self.route(key, *args, options: {}, &block)
    if not allow_multiple_associations? and map(key).present?
      return if args.count == 1 and map(key).first.klass == args.first

      raise "#{key} is already defined for the router #{self.name}"
    end

    context_key(key)
    args.each do |klass|
      to klass, options
    end
    instance_exec &block if block_given?

    context_key(nil)
    map(key)
  end

  def self.to(klass, options = {})
    raise "context_key is blank" if context_key.blank?

    # Check if the route already exists, if it does update the options
    map(context_key).each do |route|
      if route.klass == klass
        route.options = merged_options.merge(options)
        return route
      end
    end

    map(context_key) << self.use_route.new(klass, merged_options.merge(options))
  end

  def self.[](key)
    resolve(key)
  end

  def self.resolve(required_key)
    key = resolve_key(required_key)
    return nil if key.blank?

    map[key]
  end

  # Resolves and returns and relevant route matching the provided key
  # Supports wildcards: Ex: masters.*.default will match masters.categories.default
  def self.resolve_key(required_key)
    map.each_pair do |route_key, map_value|
      failed = false

      route_splits = route_key.split(".")
      required_key_splits = required_key.split(".")
      route_splits.each_with_index do |val, index|
        match = false
        match = true if val == required_key_splits[index]
        match = true if val == "*" and required_key_splits[index] != nil

        next if match

        failed = true
        break
      end

      next if failed

      return route_key
    end

    nil
  end

  def self.dispatch(key, options)
    routes = resolve(key)
    # Todo raise exception?
    return Failure("Route not found") if routes.blank?

    results = []
    resolve(key)&.each do |route|
      results << route.dispatch(options)
    end
    allow_multiple_associations? ? results : results.first
  end

  protected

  def self.scopes
    @scopes ||= []
  end

  def self.global_options
    @global_options ||= []
  end

  def self.context_key(value = NoObject)
    @context_key = value unless value == NoObject
    @context_key
  end

  # Merges the options given across all with_options
  def self.merged_options
    opt = {}
    global_options.each do |o|
      opt.merge! o
    end
    opt
  end

  def self.clear_map
    @map = {}.with_indifferent_access
  end

  def self.map(key = NoObject)
    @map ||= {}.with_indifferent_access
    return @map if key == NoObject

    @map[scoped_key(key)] ||= []
  end

  def self.scoped_key(key)
    if scopes.present?
      return "#{scopes.join(".")}.#{key}"
    end
    key
  end

end