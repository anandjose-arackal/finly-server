require 'hooks'

module CallbackHandler
  include Hooks
  attr_accessor :callback_handlers, :callback_classes

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
        define_method "#{method_name}_callback" do |model|
          if callback_handlers.present? and callback_handlers[model].present? and callback_handlers[model][method_name].present?
            callback_handlers[model][method_name].call
          end
          if callback_classes.present? and callback_classes[model].present?
            callback_classes[model].send(method_name, model)
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

  def callback_handler(model, handler)
    return unless model.present?
    # return unless handler.is_a?(CallbackHandler)
    self.callback_classes = {} if self.callback_classes.blank?
    if model.is_a?(ActiveRecord::Relation) or model.is_a?(Array)
      model.each do |m|
        m.add_callbacks(handler) rescue nil
        self.callback_classes[m] = handler
      end
    elsif model.is_a?(ActiveRecord::Base)
      model.add_callbacks(handler) rescue nil
      self.callback_classes[model] = handler
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

  class CallbackHandler
    OPERATION_HOOKS.each do |method_name|
      define_method method_name do |model|
      end
    end
  end


  ################
  # Examples
  ################
  # Method 1: By defining procs or methods
  # ##syntax -> callback_name(object, proc) -> Preferable when we just have to handle callbacks from single models classes
  # ##Example -> after_save self.report, &method(:handle_after_save) -> handle_after_save is a method that must accept an argument (model)
  # Method 2: By defining classes to handle -> Preferable when we have to handle callbacks from multiple model classes
  # ##Syntax -> callback_handler model, SaveCallBackHandler.new
  #
  #
  # Method 1
  # def subscribe
  #   after_save self.report, &method(:after_save_callback)
  # end
  #
  # def after_save_callback(model)
  #   ...
  # end
  #
  #
  # Method 2
  # def subscribe
  #   callback_handler self.report, SaveCallback.new
  # end
  #
  # class SaveCallback < CallbackHandler
  #
  #   def after_save(model)
  #   end
  #
  # end
end