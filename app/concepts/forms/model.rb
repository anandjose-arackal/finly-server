class Forms::Model

  def self.Find(model: :model)
    Transactions::Task.build id: 'find_form' do |context, **|
      context[:form] = context[model].form
    end
  end

end