class TaskManager::Documents::Index < Transactions::API
  # extend Representer::DSL

  step :load_documents

  def load_documents(options)
    # options['documents'] = Documents::Master.list
    true
  end

end