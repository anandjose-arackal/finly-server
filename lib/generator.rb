class Generator

  def self.new_transaction_id
    # 'FinlyTestRefTransId1'
    'FinlyTest1'
  end

  def self.reference_id_for(account_1, account_2, date)
    if date.blank?
      date = Date.today
    end
    if date.class.name == 'String'
      date = Date.parse date
    end
    account_1_code = (AccountManagerUtils.code_for(account_1) || '000')
    account_2_code = (AccountManagerUtils.code_for(account_2) || '000')
    prefix = "#{date.strftime('%y%m%d')}#{account_1_code}#{account_2_code}"
    ref_id =Generator.random_number(10)
    while !Generator.validate_reference_id("#{prefix}#{ref_id}")
      ref_id =Generator.random_number(10)
    end
    "#{prefix}#{ref_id}"
  end

  def self.validate_reference_id(reference_id)
    not Payment.with_reference_id(reference_id).present? and not FinlyTransaction.with_reference_id(reference_id).present?
  end

  def self.random_number(length)
    return nil if length.blank?
    unless length.class.name == Fixnum.name
      raise 'Invalid length format'
    end
    rand(length ** length).to_s.rjust(length, '0')
  end

end