# action that recomputes settlement once a report has been approved
# the user passed must be the report owner, NOT person approving it.
# params:
# report_id: id of the report being marked as approved
#

class Settlement::MoneyRequest::Approved < MoneyRequest::Base

end