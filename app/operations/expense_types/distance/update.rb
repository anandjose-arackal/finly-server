# operation that enables / disables as well as updates the respective rates for a distance and time expense
# parameters:
# distance_enabled: 0 or 1 depending on whether it's being enabled or disabled
# parent_type: 'policy'
# parent_id: id of the policy to which this configuration belongs
# distance_expense_config: {
#                rate_per_km: rate per km of the distance expense
#                default_category_id: id of the default category that the expense will be added to
#            }

class ExpenseTypes::Distance::Update < ExpenseTypes::Base


end