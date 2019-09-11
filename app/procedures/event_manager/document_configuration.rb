class EventManager::DocumentConfiguration < Transactions::API
  extend Representer::DSL

  schema do
    params do
      required(:document).filled(inclusion?: Documents::Master.list)
    end
  end

  representer :render do
    property :field_type
    property :field_key
    property :label
    collection :choices do
      property :name
      property :id
    end
    property :data_url
  end

  step :load_filters

  def load_filters(options)
    document_name = options['params'][:document]
    document = Documents::Master.for(document_name)
    options['filters'] = document.form.filters(options['current_user'])
    true
  end

end