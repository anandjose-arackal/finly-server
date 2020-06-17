class TaskManager::Documents::Configuration < Transactions::API
  # extend Representer::DSL

  schema do
    params do
      required(:document).filled#(inclusion?: Documents::Master.list)
    end
  end

  step :load_filters

  def load_filters(options)
    # document_name = options['params'][:document]
    # document = Documents::Master.for(document_name)
    # options['config'] = document.form.filters(options['current_user'])
    # true
  end

end