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

end