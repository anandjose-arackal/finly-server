class Forms::Ops::RecentDocuments < Transactions::API
	step :find_document
  step :find_recent_documents

	INCLUDED_DOCUMENTS = [Invoice].freeze

	def find_document(context, params:, current_user:, **)
    klass = params[:model].singularize.downcase == 'vendor' ? YesBankVendor : params[:model].classify.constantize rescue nil
    context[:document] = klass.present? && klass.find_by(id: params[:document_id]) if params[:document_id].present?
    return on_error context, :base, 'Document not found' unless context[:document].present?
    true
  end

	def find_recent_documents(context, params:, current_user:, **)
		recent_documents = []
		vendor_id = params[:model].singularize.downcase == 'vendor' ? context[:document].id : context[:document].vendor_id
		INCLUDED_DOCUMENTS.each do |document_class|
			recent_documents += document_class.with_vendor_ids(vendor_id).not_open.limit(10)
		end

		context[:recent_documents] = recent_documents
		true
	end
end