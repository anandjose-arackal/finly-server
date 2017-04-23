class ItzCashDmtBeneficiary < ActiveRecord::Base
  belongs_to :itz_cash_dmt_sender
  belongs_to :status, class_name: 'ItzCashDmtBeneficiaryStatus'
  belongs_to :type, class_name: 'ItzCashDmtBeneficiaryType'


end
