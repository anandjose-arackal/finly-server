class AuditTrails::Index < AuditTrails::Base
  attr_accessor :document_type, :document_id, :trails, :document
  def init

    self.document_type = params[:document_type]
    self.document_id = params[:document_id]

    # WARNING: Make sure all the classes go below belongs_to Company model
    # Check validation
    document_types = %w( PurchaseOrder Invoice )

    if document_types.include?(document_type)
      self.document = document_type.classify.constantize.find_by id: document_id
    end
  end

  def validate
    unless document_type.present? || document_id.present?
      add_message :error, 'Error in configuration'
      return
    end

    unless document.present?
      add_message :error, "Error loading #{document_type}"
      return
    end

    unless document.company_id == user.company.id
      add_message :error, "You do not have permission for this action"
    end
  end

  def process
    self.trails = document.trails
  end

  def success
    params[:trails] = self.trails
    params[:document] = self.document
    params[:document_type] = self.document_type
    AuditTrails::Index::IndexPresenter.new(user, params, messages)
  end

  class AuditTrails::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :trails, :document, :document_type

    def init
      if params[:document_type] == 'PurchaseOrder'
        self.trails = po_document_trails
      else
        self.trails = []
        all_trails = params[:trails]
        all_trails.each do |trail|
          self.trails.push trail.as_json(user)
        end

      end

    end

    def po_document_trails
      self.document = params[:document]
      if params[:document_type] == 'PurchaseOrder'
        po_trails = []
        if self.document.procurement.po_revisions.present?
          self.document.procurement.po_revisions.each do |document|
            document.trails.each do |trail|
              po_trails.push trail.as_json(user)
            end
          end
        end

        params[:trails].each do |trail|
          po_trails.push trail.as_json(user)
        end

        po_trails.sort_by!{ |doc| doc[:created_at]}
        po_trails
      end

    end

  end

end