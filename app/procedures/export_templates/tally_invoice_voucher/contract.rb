class ExportTemplates::TallyInvoiceVoucher::Contract < Transactions::Schema

  params do
    required(:company_name).filled(:string)
    required(:date).filled(:string)
    optional(:state)
    required(:voucher_type).filled(:string)
    required(:reference).filled(:string)
    required(:narration).filled(:string)
    required(:vendor).schema do
      required(:gstin).filled(:string)
      required(:gl_name).filled(:string)
      optional(:bill_allocations).array do
        hash do
          required(:name).filled(:string)
          required(:type).filled(:string)
          required(:amount).filled(:string)
        end
      end
    end
    required(:item).hash do
      required(:gl_name).filled(:string)
      optional(:category_allocations).array do
        hash do
          required(:name).filled(:string)
          required(:cost_center).filled(:string)
          required(:amount).filled(:string)
        end
      end
      required(:gst_gl).schema do
        required(:sgst).filled(:string)
        required(:cgst).filled(:string)
        required(:igst).filled(:string)
      end
    end
  end

end