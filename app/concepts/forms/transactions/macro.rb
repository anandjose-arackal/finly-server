module Forms::Transactions::Macro
  extend ActiveSupport::Concern

  class_methods do
    def Form(route:)
      Transactions::Task.build id: "forms.model.find" do |context, flow_options, circuit_options|
        current_user = context[:current_user]
        form_definition = Forms::Router.klass(route)
        next unless form_definition.present?

        context['form'] = current_user.company.forms.find_by(klass_name: form_definition.name)
        true
      end
    end
  end

end