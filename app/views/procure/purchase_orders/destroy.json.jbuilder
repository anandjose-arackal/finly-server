# if po_available, then dont redirect, otherwise redirect
json.redirect !@result.po_available
json.procurement_id @result.params[:procurement_id]
json.purchase_order_id @result.params[:purchase_order_id]
