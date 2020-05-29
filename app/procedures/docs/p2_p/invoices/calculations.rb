class Docs::P2P::Invoices::Calculations

  AMOUNT = <<-CALC
{{ row.rate | times: row.quantity }}
  CALC

  DISCOUNT_AMOUNT = <<-CALC
{{ row.amount | times: row.discount | divided_by: 100 }}
  CALC

  TAXABLE_AMOUNT = <<-CALC
{{ row.amount | minus: row.discount_amount }}
  CALC

  TAX_AMOUNT = <<-CALC
{{ row.taxable_amount | times: row.discount_amount }}
  CALC

  GROSS_TOTAL = <<-CALC
{% assign gross_total = 0 %}\
{% for item in form.line_items %}\
  {% gross_total = gross_total | plus: item.taxable_amount %}\
{% endfor %}\
{{ gross_total }}
  CALC

end