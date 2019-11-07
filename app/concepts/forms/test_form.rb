class Forms::TestForm < Forms::API

  model Invoice
  section :header do
    auto_number :invoice_id, prefix: "TF/{{\"now\" | date: \"%y-%m\" }}/", start_at: "000001"
    text :name, hint: "Please enter the name of the field", char_limit: 255
  end

  collection :line_items do
    text :item_description, hint: "Please enter the name of the field", char_limit: 255
    dropdown :status_id, choices: ['Approved', 'Pending']
    dropdown :status_id, data_provider: {klass: 'ReportStatus'}
  end

end