class Forms::Ops::Widgets < Transactions::API
  step :find_document
  step :generate_data

  VALID_WIDGETS = %w(about_document recent_invoices) 

  def find_document(context, params:, current_user:, **)
    klass = params[:model].singularize.downcase == 'vendor' ? YesBankVendor : params[:model].classify.constantize rescue nil
    context[:document] = klass.present? && klass.find_by(id: params[:document_id]) if params[:document_id].present?
    return on_error context, :base, 'Document not found' unless context[:document].present?
    true
  end

  def generate_data(context, params:, current_user:, **)
    document = context[:document]
    data = {}
    if VALID_WIDGETS.include?(params[:widget].to_s)
      data = send(params[:widget].to_s, document)
    else
      return false
    end
    context[:widget_data] = {params[:widget].to_sym => data}
    true
  end

  private

  def about_document(document)
    {
      submitted_at:     document.submitted_at,
      approved_at:      document.approved_at,
      controlling_user: document.controlling_user.name
    }
  end

  def recent_invoices(document)
    Invoice.with_vendor_ids(document.vendor_id).not_open
  end
end