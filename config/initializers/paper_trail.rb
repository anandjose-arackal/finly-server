#PaperTrail.config.track_associations = true
PaperTrail.config.enabled = true
#PaperTrail.config.object_changes_adapter = {
#                                                "delivery_location_id" => [2, 1],
#                                            "cost_center_id" => [8, 7],
#    "shipping_address" => [nil, "L-157, PSR Luxury PG For MEN, 14th A Cross, 3rd B main,\nHSR Layout, Bengaluru, Karnataka,\nBangalore, Jammu and Kashmir,\n560111"],
#    "roundoff_amount" => [-0.43, 0.45],
#    "tax_amount_id" => [
# 51820, 51824],
#    "advance_tds_amount_id" => [
#51823,
#51825],
#    "updated_at" => [
#        "Fri, 04 Sep 2020 12:56:30 IST +05:30",
#        "Fri, 04 Sep 2020 13:59:26 IST +05:30",]
#}
PaperTrail.config.object_changes_adapter =  ObjectChangeAdapter.new()