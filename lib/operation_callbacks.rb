module OperationCallbacks
  attr_accessor :callbacks_handler, :callback_classes

  def self.included(base)
    # base.send :include, InstanceMethods
    # base.extend ClassMethods

    base.class_eval do
      before_validation { handle_callback(:before_validation) }
      after_validation { handle_callback(:after_validation) }
      before_save { handle_callback(:before_save) }
      before_create { handle_callback(:before_create) }
      before_update { handle_callback(:before_update) }
      before_destroy { handle_callback(:before_destroy) }
      after_create { handle_callback(:after_create) }
      after_update { handle_callback(:after_update) }
      after_save { handle_callback(:after_save) }
      after_destroy { handle_callback(:after_destroy) }
      # after_commit { handle_callback(:after_commit) }
      # after_rollback { handle_callback(:after_rollback) }
    end
  end

  def add_callbacks(obj, callback_for=nil)
    if obj.is_a?(BaseOperation::CallbackHandler)
      self.callback_classes = [] if callback_classes.blank?
      self.callback_classes << obj
      return
    end

    return if callback_for.blank?
    self.callbacks_handler = {} if callbacks_handler.blank?
    if callbacks_handler[callback_for].blank?
      self.callbacks_handler[callback_for] = [obj]
    else
      self.callbacks_handler[callback_for] << obj
    end
  end

  def handle_callback(handle)
    if callbacks_handler.present? and callbacks_handler[handle].present?
      callbacks_handler[handle].each do |callback_handler|
        callback_handler.send("#{handle}_callback", self)
      end
    end
    if callback_classes.present?
      callback_classes.each do |callback_class|
        callback_class.send(handle, self)
      end
    end
  end

end