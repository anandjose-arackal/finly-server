class InvoicesController < BaseControllers::WebBase

  def create
    endpoint Docs::P2P::Invoices::Create
  end

  def update

  end

  def show
    endpoint Docs::P2P::Invoices::Show
  end

end
