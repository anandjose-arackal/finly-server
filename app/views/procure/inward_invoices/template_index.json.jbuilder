json.array! @result.invoice_templates do |invoice_template|
  json.extract! invoice_template, :id, :name
  json.template_name invoice_template.name
  po = invoice_template.resource
  json.extract! po, :department, :sub_department, :cost_center
  json.vendor do
    json.id
    json.name po.vendor&.name
    json.business_name po.vendor&.business_name
  end
  json.created_on DateUtils.date_formatted(po.created_at)
end