module Constants
  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_MOBILE_NUMBER = /\A(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[789]\d{9}\z/i
  VALID_PIN_CODE = /\A[1-9][0-9]{5}\z/i
  VALID_GENDER = /[MmFf]/i

  # todo - needs to be edited once we get the account details.
  ITZCASH_EMAIL_ID = 'sreeram.nr@finly.io'

  SUPERADMIN_ACCOUNTS = ['sreeram@finlytest.io', 'vivek@finlytest.io', 'veekshith@finlytest.io', 'bala@finlytest.io', 'admin@finlytest.io']

  DEFAULT_CATEGORIES = ['Education and Training', 'Travel', 'Entertainment', 'Marketing and Advertising', 'Meals', 'Office Expenses', 'Other', 'Personal']

  FLASH_COLORS = {alert: 'red', error: 'red', failure: 'red', success: 'green', message: 'blue', notice: 'blue'}

  WHITELISTED_EMAILS = ['manager4@finlytest.io', 'kaley@finlytest.io']

  class Constants::ItzCash

    MSG_QUEUE_USERNAME = "finly"
    MSG_QUEUE_PASSWORD = "Li3Wp4yk"

    MODULE = 'FINLY'
    MERCHANT_TYPE_KEY = 'DEFAULT_ITIL'
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
end
