json.results do
  json.array! @result.paginated_procurements do |p|
    json.extract! p, :id, :name, :note, :procurement_type, :transaction_id

    json.created_at p.created_at.strftime "%d %b %Y"
    json.updated_at p.receive_last_updated_at&.strftime "%d %b %Y"


    json.user do
      json.extract! p.user, :id, :name, :email, :mobile_number
    end

    if p.purchase_order.present?
      json.document 'Purchase Order'
      json.po_number p.purchase_order.po_number
    end

    po = p.purchase_order
    if po.present?
      json.po_number po.po_number
      json.po_status po.status&.name
      json.po_amount po.balance_amount
      json.location po.delivery_location
    end

    invoice = p.invoices.last

    vendor = po.present? ? po.vendor : invoice&.vendor
    if vendor.present?
      json.vendor do
        json.extract! vendor, :id, :vendor_id, :name, :created_at, :email, :mobile_number, :authorized, :description, :pan, :address, :is_deleted
        display_name = vendor.business_name || vendor.name      
        json.display_name display_name
        json.trade_name  vendor.trade_name
        json.business_name  vendor.business_name
      end
    end

    if po.present? || invoice.present?
      department = po&.department || invoice&.department
      cost_center = po&.cost_center || invoice&.cost_center
      json.department department&.full_name
      json.cost_center cost_center&.name
      json.gstin po&.gstin_location&.gstin
    end

    json.documents do
      json.array! p.receive_documents do |document|
        json.merge! document.procurement_index_details
      end
    end

    iwd = p.receive_documents&.detect {|d| d.class.name == 'InwardDocument'}

    json.grn_delivery_date iwd&.delivery_date&.strftime("%d-%m-%Y") || nil
    json.grn_received_date iwd&.updated_at&.strftime("%d-%m-%Y") || nil

  end


end

json.count @result.count