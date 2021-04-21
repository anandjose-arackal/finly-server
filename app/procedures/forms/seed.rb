class Forms::Seed

  def work(user, params)
    company = params[:record]
    return if company.blank?

    # Forms::Synchronizer.(master: 'Docs::P2P::Invoices::NonPo::Form', company_id: company.id)
    Forms::Synchronizer.(master: 'Masters::Vendors::Form', company_id: company.id)
  end

end