module Constants
  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_MOBILE_NUMBER = /\A(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[789]\d{9}\z/i
  VALID_PIN_CODE = /\A[1-9][0-9]{5}\z/i
  VALID_GENDER = /\A[MmFf]\z/i
  VALID_DECIMAL =/[\-\+]?[0-9]*(\.[0-9]+)?/i

  OTP_RESEND_INTERVAL = 60

  # todo - needs to be edited once we get the account details.
  ITZCASH_EMAIL_ID = 'veekshith.rai@finly.io'

  PRODUCT_DEMO_EMAIL_ID = ['veekshith.rai@finly.io', 'anushrut.khare@finly.io']
  # PRODUCT_DEMO_EMAIL_ID = ['sreeram.nr@finly.io']

  # RESOURCE_DOWNLOAD_EMAIL_ID = ['sreeram.nr@finly.io']
  RESOURCE_DOWNLOAD_EMAIL_ID = ['veekshith.rai@finly.io', 'anushrut.khare@finly.io']

  SUPERADMIN_ACCOUNTS = ['sreeram.nr@finly.io', 'vivek.a@finly.io', 'veekshith.rai@finly.io', 'balakumar.rajaram@finly.io', 'admin@finlytest.io']

  DEFAULT_CATEGORIES = ['Education and Training', 'Travel', 'Entertainment', 'Marketing and Advertising', 'Meals', 'Office Expenses', 'Other']

  FLASH_COLORS = {alert: 'red', error: 'red', failure: 'red', success: 'green', message: 'blue', notice: 'blue'}

  WHITELISTED_EMAILS = ['manager4@finlytest.io', 'kaley@finlytest.io', 'finance4@finlytest.io']

  if Rails.env.production?
    ITZ_CASH_KYC_EMAIL = ['kalpitap.itz@intrexindia.net']
  else
    ITZ_CASH_KYC_EMAIL = ['sreeram.nr@finly.io']
  end

  if Rails.env.production?
    ITZ_CASH_KYC_CARBON_COPY_EMAIL = ['veekshith.rai@finly.io', 'vivek.a@finly.io', 'anushrut.khare@finly.io', 'sales@finly.io']
  else
    ITZ_CASH_KYC_CARBON_COPY_EMAIL = []
  end

  # MSG91 / SendOTP API keys ######

  JUNK_IP_ADDRESSES = ['112.79.161.34', '106.209.165.14', '101.56.173.244', '49.33.120.163',
                       '223.188.21.231', '171.60.98.166', '117.225.146.193', '47.30.242.175',
                       '223.183.64.130', '223.239.47.43', '223.191.46.104', '152.52.30.232',
                       '110.224.246.31', '60.243.218.194', '1.23.161.61', '103.252.166.139',
                       '59.94.176.171', '122.174.25.83', '157.48.20.22']

  VERIFICATION_API_KEY = "-C4-IpmaywMnqaBzehqSZiP2aznU6_onhpjfiFDnxAPZBcXH-f_6JT_4fH-Qx1Y54tPjvXuShhZkCwjmroxXa7hV1dQgYede4fqAltJYivA8Cia1IvrW0FzsNaUAUFCyTXDHO1IV5-Q63zwNbzxTFw=="

  # INVITATION_API_KEY = "-C4-IpmaywMnqaBzehqSZiP2aznU6_onhpjfiFDnxAPZBcXH-f_6JT_4fH-Qx1Y54tPjvXuShhZkCwjmroxXayCwFWmM0zwoMwaBcMbNlQA0U_wBnz1AjOcjMay1VbI7bl0STMKIVQVrVVOnRe0ahA=="

  WELCOME_MESSAGE_AUTH_KEY = "126829AkHzInaT57ed5ec4"

  CURRENCY_LAYER_ACCESS_KEY = "149cdc66258ab026ca6d0c4841827503"

  # PayU Payment Gateway URL
  if Rails.env.production?
    PAYU_RELOAD_URL = "https://www.itzcash.com/finly/servlet/AccountReloadServlet"
  else
    PAYU_RELOAD_URL = "https://staging.itzcash.com/loconav/servlet/AccountReloadServlet"
  end

  #########################

  if Rails.env.production?
    TRANSCRIBER_EMAILS = %w(veekshith.rai@finly.io vivek.a@finly.io anushrut.khare@finly.io abhinandanyadavg@gmail.com)
  else
    TRANSCRIBER_EMAILS = ['sreeram.nr@finly.io']
  end

  #### Date before which statements won't be accurate
  BEGINNING_OF_TIME = '10-03-2017'
  ###################################################


  if Rails.env.development?
    # url = "http://192.168.81.157:3000/#"
    url = "http://localhost/#"
    authorizer_url = "http://localhost/authorizer#"
  elsif Rails.env.staging?
    url = "http://staging.finly.io/#"
    authorizer_url = "http://staging.finly.io/authorizer#"
  elsif Rails.env.itzcash_uat?
    url = "http://demo.finly.io/#"
    authorizer_url = "http://demo.finly.io/authorizer#"
  elsif Rails.env.local_vm?
    url = "http://192.168.56.101/#"
    authorizer_url = "http://192.168.56.101/authorizer#"
  elsif Rails.env.production?
    url = "https://www.finly.io/#"
    authorizer_url = "https://www.finly.io/authorizer#"
  else
    url = ""
    authorizer_url = ""
  end

  BASE_URL = url
  BASE_URL_AUTHORIZER = authorizer_url

  DEFAULT_PASSWORD = "lqskmclkmsal1k"

  class Constants::ItzCash

    ICW_CODE = 'D000000360'
    DMT_USERNAME = 'itzic20000'
    DMT_PASSWORD = '03jqURp0OO0aVkssyuy01g=='
    EASY_WALLET_ID = 'IFTSPL IMPS Wallet'
    EASY_WALLET_TYPE = 'IMPS'

    DMT_PAYMENT_MODE = 'easyPay'

    BENEFICIARY_REGISTRATION_RELATION = 'Friend'
    IFSC_OPTION = 'ByIfsc'
    PROCESSING_BANK_ID = 'RMB000000000002'
    PROCESSING_BANK_NAME = 'ItzCash Card Ltd'

    RESTRICTION_BUDGET_CONSTANT = 1000000
    RESTRICTION_TRANS_CONSTANT = 1000

    MSG_QUEUE_USERNAME = "finly"
    MSG_QUEUE_PASSWORD = "Li3Wp4yk"

    MODULE = 'FINLY'

    if Rails.env.production?
      MERCHANT_TYPE_KEY_CREDIT = 'OLCEXP_CARDTOPUP'
      MERCHANT_TYPE_KEY_DEBIT = 'OLCEXP_CARDDEBIT'
      PRODUCT_CODE = 'HDFFIN'
      PRODUCT_CODE_HDFC_EXPENSE_CARD = 'HDFFIN'
      PRODUCT_CODE_RBL_EXPENSE_CARD = 'RBLRFN'
    else
      MERCHANT_TYPE_KEY_CREDIT = 'DEFAULT_ITIL'
      MERCHANT_TYPE_KEY_DEBIT = 'DEFAULT_ITIL'
      PRODUCT_CODE = 'NGPRHD'
    end

    # PRODUCT_CODE = 'NGPRHD'
    # CHARGE_CODE = 'GPRESC'
    TRANSACTION_TYPE_CREDIT = 1
    TRANSACTION_TYPE_DEBIT = 2
    OPERATION_TYPE_BLOCK = 'B'
    OPERATION_TYPE_UNBLOCK = 'U'

    # DUMMY_DCODE = 'D000000360'

    # G = Assigned
    # M = Material Inward
    # F = Stock Transfer
    # I = Invoiced (Activated)
    # A = Active (In Use)
    # B = Blocked
    # X = Expired
    # D = Damaged
    CARD_STATUS_CODE = {G: 'Assigned', M: 'Pending', F: 'Issued',
                        I: 'Activated', A: 'Active', B: 'Blocked',
                        X: 'Expired', D: 'Damaged'}

    ERROR_CODES = {-4000 => 'You are not authorized to access this service',
                   -3090 => 'Transaction verification failure',
                   -3030 => 'Transaction Amount exceeds maximum permitted amount',
                   -3021 => 'Invalid Order ID',
                   -3020 => 'Invalid Input Details',
                   -3010 => 'Insufficient balance in the card to do this transaction',
                   -3009 => 'Invalid configuration',
                   -3004 => 'Internal error processing the request',
                   -3001 => 'Invalid Amount',
                   -3000 => 'Invalid Merchant Type Key',
                   -2024 => 'Insufficient funds in company account to initiate this transfer',
                   -1001 => 'Refund is not allowed',
                   -1000 => 'Refund failed',
                   -634 => 'Invalid OTP',
                   -601 => 'Timeout',
                   -550 => 'Invalid mobile number provided',
                   -542 => 'External call returned error',
                   -541 => 'Invalid option selected',
                   -540 => 'Error calling external URL',
                   -527 => 'Error sending SMS',
                   -526 => 'Error sending email',
                   -515 => 'Error inserting or updating records',
                   -514 => 'Error updating records',
                   -513 => 'Unable to fetch data',
                   -512 => 'Error inserting record. Sanity Check failed',
                   -511 => 'Error inserting record',
                   -510 => 'No records found',
                   -500 => 'Could not fetch details',
                   -499 => 'Error activating card',
                   -498 => 'Error converting card',
                   -311 => 'Transaction on this card cannot be done using this merchant',
                   -199 => 'Card expired',
                   -198 => 'Card is damaged',
                   -197 => 'Max balance exceeded (Full KYC)',
                   -196 => 'Cannot process refunds due to insufficient balance',
                   -195 => 'Transaction not permitted as it exceeds the annual cash limit',
                   -150 => 'Transaction not permitted as it exceeds the annual or monthly limits',
                   -138 => 'Debit amount is too large',
                   -137 => 'Credit amount is too large',
                   -134 => 'Card blocked',
                   -132 => 'Transaction cannot be confirmed',
                   -131 => 'Transaction has timed out',
                   -130 => 'Transaction is reverted',
                   -129 => 'Transaction is confirmed',
                   -125 => 'Invalid request data',
                   -124 => 'IP address is not allowed',
                   -123 => 'Transaction amount is too large',
                   -122 => 'Max balance exceeded (Basic KYC)',
                   -117 => 'Invalid account status',
                   -114 => 'Invalid Card Status. Card not activated or suspended or blocked',
                   -107 => 'Invalid Transaction Type',
                   -106 => 'Invalid Amount',
                   -104 => 'Internal error processing the request',
                   -100 => 'Internal error processing the request',
                   0 => 'Success',
                   2 => 'Transaction is already confirmed',
                   5 => 'Account has no balance',
                   300 => 'Unknown status. Card may have been credited',
                   301 => 'Transaction status unknown. Card may have been credited',
                   305 => 'Card Activation was successful but reload failed',
                   306 => 'Card Activation was successful. Error during reload',
                   307 => 'Card is already activated',
                   3100 => 'Transaction is already confirmed'}
  end

  class Constants::YesBank
    PROCESSING_TRANSACTION_STATUSES = ["SENT_TO_BENEFICIARY", "IN-PROCESS","IN_PROCESS", "SCHEDULED_FOR_NEXT_WORKDAY"]
    FAILED_TRANSACTION_STATUSES = ["FAILED", "RETURNED_FROM_BENEFICIARY"]
    SUCCESSFUL_TRANSACTION_STATUSES = ["COMPLETED"]
  end
end
