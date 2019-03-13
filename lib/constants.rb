module Constants
  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_DOMAIN = /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z0-9]{1,5}(.[a-z0-9]{1,5})?(:[0-9]{1,5})?(\/.*)?$\z/i
  VALID_MOBILE_NUMBER = /\A(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[6789]\d{9}\z/i
  VALID_PIN_CODE = /\A[1-9][0-9]{5}\z/i
  VALID_GENDER = /\A[MmFf]\z/i
  VALID_DECIMAL =/[\-\+]?[0-9]*(\.[0-9]+)?/i
  VALID_IFSC = /[A-Za-z]{4}[a-zA-Z0-9]{7}/i
  VALID_BANK_ACCOUNT = /\A[A-Za-z0-9]{3,32}\z/i
  ENDING_NUMBERS = /\d+$/
  OTP_RESEND_INTERVAL = 60

  # todo - needs to be edited once we get the account details.
  if Rails.env.production?
    ITZCASH_EMAIL_ID = ['veekshith.rai@finly.io', 'vivek.a@finly.io', 'sabhishek@itzcash.com']
    YESBANK_EMAIL_ID = ['veekshith.rai@finly.io', 'vivek.a@finly.io']
  else
    ITZCASH_EMAIL_ID = ['sreeram.nr@finly.io']
    YESBANK_EMAIL_ID = ['sreeram.nr@finly.io']
  end

  # todo - to be removed once companies are done migrating from HDFC to RBL
  MIGRATING_COMPANIES = []

  # PRODUCT_DEMO_EMAIL_ID = ['veekshith.rai@finly.io', 'anushrut.khare@finly.io', 'venu.reddy@finly.io']
  PRODUCT_DEMO_EMAIL_ID = ['venu.reddy@finly.io', 'kashyap.bj@finly.io', 'ankit.bazari@finly.io', 'chandra@finly.io']
  # PRODUCT_DEMO_EMAIL_ID = ['sreeram.nr@finly.io', 'kumar.abinash@finly.io']

  # RESOURCE_DOWNLOAD_EMAIL_ID = ['sreeram.nr@finly.io']
  # RESOURCE_DOWNLOAD_EMAIL_ID = ['veekshith.rai@finly.io', 'anushrut.khare@finly.io', 'kartik.k@finly.io', 'venu.reddy@finly.io']
  RESOURCE_DOWNLOAD_EMAIL_ID = ['venu.reddy@finly.io']

  SUPERADMIN_ACCOUNTS = ['sreeram.nr@finly.io', 'vivek.a@finly.io', 'veekshith.rai@finly.io', 'admin@finlytest.io']

  DEFAULT_CATEGORIES = ['Education and Training', 'Travel', 'Entertainment', 'Marketing and Advertising', 'Meals', 'Office Expenses', 'Other']
  DEFAULT_MONEY_REQUEST_CATEGORIES = ['Accommodation', 'Lodging', 'Local Conveyance', 'Others']

  FLASH_COLORS = {alert: 'red', error: 'red', failure: 'red', success: 'green', message: 'blue', notice: 'blue'}

  WHITELISTED_EMAILS = ['manager4@finlytest.io', 'kaley@finlytest.io', 'finance4@finlytest.io']

  if Rails.env.production?
    ITZ_CASH_KYC_EMAIL = ['kalpitap.itz@intrexindia.net']
  else
    ITZ_CASH_KYC_EMAIL = ['sreeram.nr@finly.io']
  end

  if Rails.env.production?
    ITZ_CASH_KYC_CARBON_COPY_EMAIL = ['veekshith.rai@finly.io', 'vivek.a@finly.io', 'anushrut.khare@finly.io', 'sales@finly.io', 'kartik.k@finly.io']
  else
    ITZ_CASH_KYC_CARBON_COPY_EMAIL = []
  end


  JUNK_IP_ADDRESSES = ['112.79.161.34', '106.209.165.14', '101.56.173.244', '49.33.120.163',
                       '223.188.21.231', '171.60.98.166', '117.225.146.193', '47.30.242.175',
                       '223.183.64.130', '223.239.47.43', '223.191.46.104', '152.52.30.232',
                       '110.224.246.31', '60.243.218.194', '1.23.161.61', '103.252.166.139',
                       '59.94.176.171', '122.174.25.83', '157.48.20.22']

  # MSG91 / SendOTP API keys ######
  VERIFICATION_API_KEY = "-C4-IpmaywMnqaBzehqSZiP2aznU6_onhpjfiFDnxAPZBcXH-f_6JT_4fH-Qx1Y54tPjvXuShhZkCwjmroxXa7hV1dQgYede4fqAltJYivA8Cia1IvrW0FzsNaUAUFCyTXDHO1IV5-Q63zwNbzxTFw=="

  # INVITATION_API_KEY = "-C4-IpmaywMnqaBzehqSZiP2aznU6_onhpjfiFDnxAPZBcXH-f_6JT_4fH-Qx1Y54tPjvXuShhZkCwjmroxXayCwFWmM0zwoMwaBcMbNlQA0U_wBnz1AjOcjMay1VbI7bl0STMKIVQVrVVOnRe0ahA=="


  if Rails.env.production?
    WELCOME_MESSAGE_AUTH_KEY = "126829AkHzInaT57ed5ec4"
  else
    WELCOME_MESSAGE_AUTH_KEY = ""
  end

  # CURRENCY_LAYER_ACCESS_KEY = "149cdc66258ab026ca6d0c4841827503"
  # using the below one because the above one's monthly quota was crossed
  CURRENCY_LAYER_ACCESS_KEY = "5ca7968931344d3315596dc05a7249d1"

  # PayU Payment Gateway URL
  if Rails.env.production?
    PAYU_RELOAD_URL = "https://www.itzcash.com/finly/servlet/AccountReloadServlet"
  else
    PAYU_RELOAD_URL = "https://staging.itzcash.com/loconav/servlet/AccountReloadServlet"
  end

  #########################

  if Rails.env.production?
    TRANSCRIBER_EMAILS = %w(abhinandan.k@finly.io rakesh.g@finly.io)
  else
    TRANSCRIBER_EMAILS = ['sreeram.nr@finly.io']
  end

  #### Date before which statements won't be accurate
  BEGINNING_OF_TIME = '10-03-2017'
  ###################################################

  if Rails.env.production?
    SPECIAL_RESPONSE_EMAIL = 'yb_special_response@finly.io'
  else
    SPECIAL_RESPONSE_EMAIL = 'yb_special_response@emaildev.finly.io'
  end


  if Rails.env.development?
    # url = "http://192.168.81.157:3000/#"
    url = "http://localhost/#"
    authorizer_url = "http://localhost/authorizer#"
    vendor_payments_url = "http://localhost/payments#"
    assets_url = "localhost"
  elsif Rails.env.staging?
    url = "http://staging.finly.io/#"
    authorizer_url = "http://staging.finly.io/authorizer#"
    vendor_payments_url = "http://staging.finly.io/payments#"
    assets_url = "https://www.staging.finly.io"
  elsif Rails.env.itzcash_uat?
    url = "http://demo.finly.io/#"
    authorizer_url = "http://demo.finly.io/authorizer#"
    vendor_payments_url = "http://demo.finly.io/payments#"
    assets_url = "https://www.demo.finly.io"
  elsif Rails.env.local_vm?
    url = "http://192.168.56.101/#"
    authorizer_url = "http://192.168.56.101/authorizer#"
    vendor_payments_url = "http://192.168.56.101/payments#"
    assets_url = ""
  elsif Rails.env.production?
    url = "https://www.finly.io/#"
    authorizer_url = "https://www.finly.io/authorizer#"
    vendor_payments_url = "http://www.finly.io/payments#"
    assets_url = "https://www.finly.io"
  else
    url = ""
    authorizer_url = ""
    vendor_payments_url = ""
    assets_url = ""
  end

  BASE_URL = url
  BASE_URL_AUTHORIZER = authorizer_url
  BASE_URL_VP = vendor_payments_url
  BASE_ASSETS_URL = assets_url

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

  # YSE CARD STATUS
  # Active
  # Locked
  # Blocked
  # Hot Listed
  # Hot Listed for Damage
  # Closed
  # Blocked for Damage
  # Blocked - Card Stolen
  # Kept Aside
  # Dispatched
  # Generated
  # Generated - Pin Mailer Pending
  # Pin Mailer Printed
  # Pin Mailer Printed - Embossing pending
  # Embossed
  CARD_PROCESSOR_STATUS = {
      active: 'Active',
      locked: 'Locked',
      blocked: 'Blocked',
      hotlisted: 'Hot Listed',
      hotlisted_for_damage: 'Hot Listed for Damage',
      closed: 'Closed',
      blocked_for_damage: 'Blocked for Damage',
      blocked_card_stolen: 'Blocked - Card Stolen',
      kept_aside: 'Kept Aside',
      dispatched: 'Dispatched',
      generated: 'Generated',
      generated_pin_mailer_pending: 'Generated - Pin Mailer Pending',
      pin_mailer_printed: 'Pin Mailer Printed',
      pin_mailer_printed_embossing_pending: 'Pin Mailer Printed - Embossing pending',
      embossed: 'Embossed'
  }

  class Constants::YesBank
    PROCESSING_TRANSACTION_STATUSES = ["SENT_TO_BENEFICIARY", "IN-PROCESS","IN_PROCESS", "SCHEDULED_FOR_NEXT_WORKDAY"]
    FAILED_TRANSACTION_STATUSES = ["FAILED", "RETURNED_FROM_BENEFICIARY", "REQUEST NOT FOUND"]
    SUCCESSFUL_TRANSACTION_STATUSES = ["COMPLETED"]

    YES_BANK_RECEIVING_IFSC = "YESB0000022"
    YES_BANK_COLLECT_IFSC = 'YESB0CMSNOC'
  end

  ################### Encryption Keys for Darwin Box ################

  class Constants::Darwinbox
    if Rails.env.production?
      XOR_KEY = ''
    else
      XOR_KEY = '666666'
    end

    if Rails.env.production?
      SHA512_KEY = ''
    else
      SHA512_KEY = '4150fb44a955a5ff0711f9a1c631a3ed'
    end
  end

  ###################### END OF Darwin Box ###########################


  ################### Encryption Keys for Remunance ################

  class Constants::Remunance
    if Rails.env.production?
      XOR_KEY = ''
    else
      XOR_KEY = '666666'
    end

    if Rails.env.production?
      SHA512_KEY = ''
    else
      SHA512_KEY = '4150fb44a955a5ff0711f9a1c631a3ed'
    end
  end

  ###################### END OF Remunance ###########################

end