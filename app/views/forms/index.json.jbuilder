forms = @op["model.index"]
# json.forms forms
json.result do
  json.array!(forms) do |form|

    model_name = form.model.name
    if form.klass_name == "Masters::Vendors::Form"
      model_name = 'Vendor'
    elsif form.klass_name == "Docs::P2P::Invoices::NonPo::Form"
      model_name = 'Invoice'
    elsif form.klass_name == "Docs::P2P::Invoices::Po::Form"
      model_name = 'PoInvoice'
    end

    json.extract! form, :id, :updated_at
    json.document_name model_name
  end
end


