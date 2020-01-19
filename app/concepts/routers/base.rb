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

  def self.route(key, *args, options: {})
    if not allow_multiple_associations? and map(key).present?
      raise "#{key} is already defined for the router #{self.class.name}"
    end

    args.each do |klass|
      map(key) << self.use_route.new(klass, merged_options.merge(options))
    end
    map(key)
  end

  def self.resolve(key)
    map[key]
  end

  def self.dispatch(key, options)
    routes = map[key]
    # Todo raise exception?
    return Failure() if routes.blank?

    results = []
    map[key]&.each do |route|
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

  # Merges the options given across all with_options
  def self.merged_options
    opt = {}
    global_options.each do |o|
      opt.merge! o
    end
    opt
  end

  def self.map(key = NoObject)
    @map ||= {}
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

# class Router
#
#   def draw(&block)
#     instance_exec &block
#   end
#
#   def scopes
#     @scopes ||= []
#   end
#
#   def scope(key, &block)
#     scopes.push key
#     instance_exec &block
#     scopes.pop
#   end
#
#   def route(key, *args)
#     args.each { |arg| map(key) << arg }
#     map(key)
#   end
#
#   def map(key = NoObject)
#     @map ||= {}
#     return @map if key == NoObject
#
#     if scopes.present?
#       key = "#{scopes.join(".")}.#{key}"
#     end
#     @map[key] ||= []
#   end
#
# end