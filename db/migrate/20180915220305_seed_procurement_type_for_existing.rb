class SeedProcurementTypeForExisting < ActiveRecord::Migration[4.2]
  def change
    procurements = Procurement.all

    procurements.each do |procurement|
      if procurement.procurement_type.blank?
        procurement.update(procurement_type: 'purchase_order')
      else
        unless procurement.procurement_type == 'invoice' || procurement.purchase_order.present?
          procurement.update(procurement_type: 'purchase_order')
        end
      end
    end
  end
end
