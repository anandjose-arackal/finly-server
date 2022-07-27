class CreditNoteMigrator
  def self.perform(company_id)
    company = Company.find(company_id)

    ActsAsTenant.with_tenant(company) do
      documents = CreditNote.where(company_id: company_id)

      form = Form.where(klass_name: 'Docs::P2P::CreditNotes::Form', company_id: company_id).first
      documents.find_in_batches(batch_size: 1000) do |batch|
        batch.each do |document|
          update_item document
          update_credit_note_details document
          migrate_cn_attachment document
        end
      end
    end
  end

  def update_item(document)
    document.items.each do |item|
      update_params = {
        cn_original_taxable_amount: item.original_taxable_amount&.value.to_f,
        cn_revised_taxable_amount: item.revised_taxable_amount&.value.to_f,
        item_total_amount: item.total_amount&.value
      }
      item.skip_callback = true
      item.update_columns
    end
  end

  def update_credit_note_details(document)
    true
  end

  def migrate_cn_attachment(document)
    true
  end
end