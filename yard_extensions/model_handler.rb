# YARD documentation keeps models and concerns in the root directory as they are not namespaced.
# This creates a lot of root level classes which makes it hard to read the documentation
#
# This module has 2 responsibilities
# 1. Add Models namespace to all the models
# 2. Add Models::Concerns namespaces to all model/concerns
module ModelHandler

  def process
    if statement[0].file.to_s.start_with?("app/models")
      model_namespace = YARD::CodeObjects::NamespaceObject.new(namespace, 'Models')
      if statement[0].file.to_s.start_with?("app/models/concerns")
        model_namespace = YARD::CodeObjects::NamespaceObject.new(model_namespace, 'Concerns')
      end
      push_state(namespace: model_namespace) do
        super
      end
    else
      super
    end
  end

end

# prepend allows calling +super+ to trigger the original class method. Cleaner way of monkey patching
# include replaces the method, thus making the code in the original class inaccessible
# If we include it instead of prepending it, then we cannot call +super+ to trigger the original class method
# Reference: https://stackoverflow.com/questions/4470108/when-monkey-patching-an-instance-method-can-you-call-the-overridden-method-from
YARD::Handlers::Ruby::ClassHandler.prepend ModelHandler
YARD::Handlers::Ruby::ModuleHandler.prepend ModelHandler