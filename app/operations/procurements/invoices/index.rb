class Procurements::Invoices::Index < Procurements::Invoices::Base
  attr_accessor :invoices, :policies
  def init
  end

  def validate
  end

  def process
    # Only used for getting pending approval
    if user.vendor_payments_reviewer?
      level_ids = []
      policy_ids = user.company.policies.with_application(:vp).pluck(:id)

      policy_level_ids = ReviewalLevel.with_entity_type('Invoice').with_policy_ids(policy_ids).pluck(:id)

      reviewer_level_ids = LevelReviewerMapping.with_reviewer_id(user.id).pluck(:level_id)

      level_ids = policy_level_ids & reviewer_level_ids

      # Find all the invoices with controlling level from above
      invoice_ids = user.company.inward_invoices.with_controlling_level_ids(level_ids).pluck(:id)

      # Find all document level reviewer mapping with with the above list of level + reviewer and get their po id
      invoice_ids += ::DocumentLevelReviewerMapping.with_level_ids(level_ids).with_reviewer_ids(user.id).with_document_type('Invoice').pluck(:document_reviewer_mappable_id)

      # Find all document level reviewer mappings with above list of level + NOT reviewer and their invoices
      other_reviewer_invoice_ids = ::DocumentLevelReviewerMapping.with_level_ids(level_ids).not_with_reviewer_ids(user.id).with_document_type('Invoice').pluck(:document_reviewer_mappable_id)

      invoice_ids -= other_reviewer_invoice_ids

      self.invoices = user.company.inward_invoices.with_id(invoice_ids).with_status_ids(InwardInvoiceStatus.id_for(:processing))

      all_level_ids = self.invoices.pluck(:controlling_level_id)

      self.invoices = self.invoices.with_controlling_level_ids(level_ids & all_level_ids)
    end
  end

  def success
    params[:invoices] = self.invoices
    Procurements::Invoices::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoices

    has_scope :filter_inward_invoice_type

    def init
      self.invoices = params[:invoices]

      self.invoices = apply_scopes(self.invoices, params)
    end

  end
end