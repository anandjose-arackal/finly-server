# action that recomputes settlement once a report is unapproved
# user passed must be report owner and NOT report person unapproving it
# params:
# report_id: id of the report that is being unapproved


class Settlement::MoneyRequest::Unapproved < MoneyRequest::Base

end