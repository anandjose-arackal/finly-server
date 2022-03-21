namespace :form_actions do
  desc 'Reset Form'
  task :reset_form, [:company_id, :model] => [:environment] do |task, args|
    company_id = args[:company_id].to_i
    if company_id.nil?
      p 'No company id provided'
      return
    end
    ActsAsTenant.current_tenant = Company.find(company_id)
    masters = {
      po_invoice: 'Docs::P2P::Invoices::Po::Form',
      poi: 'Docs::P2P::Invoices::Po::Form',
      non_po_invoice: 'Docs::P2P::Invoices::NonPo::Form',
      npoi: 'Docs::P2P::Invoices::NonPo::Form',
      po: 'Docs::P2P::PurchaseOrders::Form',
      purchase_order: 'Docs::P2P::PurchaseOrders::Form',
      purchase_request: 'Docs::P2P::PurchaseRequests::Form',
      pr: 'Docs::P2P::PurchaseRequests::Form',
      vendor: 'Masters::Vendors::Form'
    }
    model = args[:model]
    if model.nil?
      master = 'Docs::P2P::PurchaseOrders::Form'
      Form.where(klass_name: master).first.destroy rescue nil
      Forms::Synchronizer.(master: master, company_id: company_id)
      master = 'Docs::P2P::Invoices::Po::Form'
      Form.where(klass_name: master).first.destroy rescue nil
      Forms::Synchronizer.(master: master, company_id: company_id)
      master = 'Docs::P2P::PurchaseRequests::Form'
      Form.where(klass_name: master).first.destroy rescue nil
      Forms::Synchronizer.(master: master, company_id: company_id)
    else
      master = masters[model.to_sym]
      if master.nil?
        p 'Wrong model name'
        return
      end
      Form.where(klass_name: master).first.destroy rescue nil
      Forms::Synchronizer.(master: master, company_id: company_id)
    end
  end

  task :show_field, [:company_id, :model, :entity_key] => [:environment] do |task, args|
    company_id = args[:company_id].to_i
    if company_id.nil?
      p 'No company id provided'
      return
    end
    ActsAsTenant.current_tenant = Company.find(company_id)
    masters = {
      po_invoice: 'Docs::P2P::Invoices::Po::Form',
      poi: 'Docs::P2P::Invoices::Po::Form',
      non_po_invoice: 'Docs::P2P::Invoices::NonPo::Form',
      npoi: 'Docs::P2P::Invoices::NonPo::Form',
      po: 'Docs::P2P::PurchaseOrders::Form',
      purchase_order: 'Docs::P2P::PurchaseOrders::Form',
      purchase_request: 'Docs::P2P::PurchaseRequests::Form',
      pr: 'Docs::P2P::PurchaseRequests::Form',
      vendor: 'Masters::Vendors::Form'
    }
    model = args[:model]
    master = masters[model.to_sym]
    if model.nil?
      p 'wrong form model'
      return
    else
      form = Form.where(klass_name: master).first
      if form.nil?
        p 'Form not present'
        return
      end
      entity_key = args[:entity_key]
      entity = form.entities.where(entity_key: entity_key).first
      if entity.nil?
        p 'Wrong entity key'
        return
      end
      entity.update(visible: true)
      p "Entity made visible: #{entity.label}"
    end
  end
end
