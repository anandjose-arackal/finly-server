class Forms::TestForm < Forms::API

  model Invoice
  section :header do
    auto_number :invoice_id, prefix: "TF/{{\"now\" | date: \"%y-%m\" }}/", start_at: "000001"
    text :name, hint: "Please enter the name of the field", char_limit: 255
  end

  section :line_items do
    collection :line_items do
      text :item_description, hint: "Please enter the name of the field", char_limit: 255
      dropdown :status_id, choices: [{value: 1, name: 'Approved'}, {value: 1, name: 'Pending'}]
      dropdown :department_id, auto_complete: {route: 'departments', filters: {}}
      # dropdown :location_id, choices: ReportStatus.all.as_json
    end
  end

end