class Forms::Contracts::Builder
  include DynamicAttributes

  class_attr :form

  def self.properties
    @properties ||= []
  end

  def self.property(name, options = {}, &block)
    properties << Forms::Contracts::Property.new(name, options, block, collection: false)
  end

  def self.collection(name, options = {}, &block)
    properties << Forms::Contracts::Property.new(name, options, block, collection: true)
  end

  def self.functions(&block)
    @functions = block if block_given?
    @functions
  end

  def self.user_scope(scope = NoObject)
    @user_scope = scope unless scope == NoObject
    @user_scope
  end

  def self.define_user_scope
    scope = user_scope
    lambda do |*args|
      define_method :user_scope do
        return nil unless scope.present?

        user = send(scope)
        if scope.to_s.ends_with?('_id') and not user.class.to_s == User.name
          User.find_by(id: send(scope))
        else
          user
        end
      end
    end
  end

  def self.build(user)
    form = self.form
    properties = self.properties
    functions = self.functions
    user_scope = define_user_scope
    klass = Class.new(Transactions::Contract) do
      properties.each do |prop|
        instance_eval &prop.build(form)
      end

      class_eval &functions if functions.present?
      class_eval &user_scope if user_scope.present?
    end
    klass.send :model, form.model if form&.model
    klass
  end

end