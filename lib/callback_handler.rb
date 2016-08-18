require 'hooks'

module CallbackHandler
  include Hooks
  attr_accessor :callback_handlers #, :callback_classes

  OPERATION_HOOKS = [:before_validation, :after_validation, :before_save, :before_create, :before_update,
                     :before_destroy, :after_create, :after_update, :after_save, :after_destroy]

  def self.included(base)
    base.class_eval do
      include Hooks
      attr_accessor :callback_handlers

      OPERATION_HOOKS.each do |op_hook|
        define_hook op_hook
      end

      OPERATION_HOOKS.each do |method_name|
        define_method "#{method_name}_callback" do |arg|
          if callback_handlers.present? and callback_handlers[method_name].present?
            callback_handlers[method_name].each do |handle|
              handle.call(arg)
            end
          end
        end
      end

      OPERATION_HOOKS.each do |method_name|
        define_method method_name do |model, &handle|
          if model.is_a?(ActiveRecord::Relation) or model.is_a?(Array)
            model.each do |m|
              receive_callbacks_for m, method_name, &handle
            end
          elsif model.is_a?(ActiveRecord::Base)
            receive_callbacks_for model, method_name, &handle
          end
        end
      end
    end
  end

  class CallbackHandler
    OPERATION_HOOKS.each do |method_name|
      define_method method_name do
      end
    end
  end

  def receive_callbacks_for(model, method_name, &handle)
    return unless model.present?
    model.add_callbacks(self, method_name) rescue nil
    if self.callback_handlers.blank?
      self.callback_handlers = {}
    end
    if self.callback_handlers[model].blank?
      self.callback_handlers[model] = {}
    end
    self.callback_handlers[model][method_name] = handle
  end

end