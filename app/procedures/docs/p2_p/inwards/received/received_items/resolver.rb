class Docs::P2P::Inwards::Received::ReceivedItems::Resolver < Resolver::API

  entity InwardDocument

  def load(params)
    inward_doc = Resolver::Router.dispatch('inward_documents.received', { params: params, current_user: user })
    InwardDocumentItem.where "inward_document_id  in (#{inward_doc.select('id').to_sql})"
  end
end