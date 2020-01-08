class Bbps::TransactionStatus < Bbps::Api

  schema do
    params do
      required(:order_number).filled
    end
  end

  path "getTxnStatus"

  # Message Code(B4000)|Ref No| Agent institution Id | Channel Id|Agent Id | Complaint Type|
  # Order No|Mobile No| From Date|To Date|
  # Additional Field 1| Additional Field 2|Additional Field 3| Additional Field 4| Additional Field 5|
  # Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10|
  # Additional Field 11 |Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15
  #
  # Example 1: with Transaction Ref ID
  # B4000|FETCHREFAGENTE6A4170322501317|YS01|C1001 |18799 |O|
  # FETCHREFAGENTE6A41703399921007| NA|NA|NA| NA| NA| NA| NA| NA| NA| NA| NA| NA| NA| NA| NA| NA| NA| NA
  request_fields(
      [
          :message_code, :ref_number, :agent_institution_id, :channel_id, :agent_id,
          :complaint_type, :order_number, :mobile_number, :from_date, :to_date,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )

  # Message Code(B4001)|Status |Error Code |Error Desc | Ref No |Agent institution Id |
  # Channel Id| BBPS Transaction Reference ID|Agent Id | {txn details}|
  # Additional Field 1| Additional Field 2| Additional Field 3| Additional Field 4| Additional Field 5|
  # Additional Field 6| Additional Field 7| Additional Field 8| Additional Field 9| Additional Field 10|
  # Additional Field 11 |Additional Field 12| Additional Field 13| Additional Field 14| Additional Field 15
  #
  # Example 1: With Transaction Ref Number
  # B4001|Y|000|Success|FETCHREFAGENTE6A4170322501317|YS01|C1001|YS0107112115|YS 01AB21000001123123|
  # {\"TxnStatusComplainResp\": {\"txnList\":{\"txnDetail\":[{\"txnReferenceId\":\"YS0107112115\",\"amount\":
  # \"100\",\"txn Date\":\"2017-06- 07T11:19:15+05:30\",\"agentId\":\"YS01AB21000001123123\",\"billerId\":
  # \"TSTW00000VSP09 \",\"txnStatus\":\"SUCCESS\"}]},\"customerDetails\":{\"name\":null,\"email\":null,
  # \"mobile \":\"9898990007\"},\"msgId\":\"COMPLAINTMSG61E72009A64170609123344\",\"complaintI d\":null,
  # \"openComplaint\":null,\"complaintStatus\":null,\"assigned\":null,\"responseCode\ ":\"000\",
  # \"responseReason\":\"SUCCESS\"}}|NA|NA|NA|NA|NA|NA|NA|NA|NA|N A|NA|NA|NA|NA|NA
  #
  # NOT BEING USED AT THE MOMENT
  # Example 2: With Mobile no and Date
  # B4001|Y|000|Success|FETCHREFAGENTE6A4170424154703|YS01|C1001|YS0118184752|YS 01AB21000001123123|
  # {\"TxnStatusComplainResp\": {\"txnList\":{\"txnDetail\":[{\"txnReferenceId\":\"YS0118184752\",
  # \"amount\":\"100\",\"txn Date\":\"2017-04- 18T18:45:52+05:30\",\"agentId\":\"YS01AB21000001123123\",
  # \"billerId\":\"TSTV00000GUJ08\ ",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0116132464\",
  # \"amount\":\"100\",\"t xnDate\":\"2017-04- 18T16:13:06+05:30\",\"agentId\":\"KC01KC01INB519686490\",
  # \"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0113132287\",
  # \"amount\":\"100\",\ "txnDate\":\"2017-04- 18T13:11:35+05:30\",\"agentId\":\"KC01KC01INB519686490\",
  # \"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0116130994\",
  # \"amount\":\"100\",\ "txnDate\":\"2017-04- 17T16:35:27+05:30\",\"agentId\":\"EQ01EQ01BNK524669103\",
  # \"billerId\":\"TSTV00000GUJ0 8\",\"txnStatus\":\"REVERSAL\"},{\"txnReferenceId\":\"PT01C46C68B0\",
  # \"amount\":\"100 \",\"txnDate\":\"2017-04- 17T16:06:51+05:30\",\"agentId\":\"PT01PT01527118732216\",
  # \"billerId\":\"TSTV00000GUJ08\",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"PT012CF9A830\",
  # \"amount\":\"100\",\" txnDate\":\"2017-04- 17T16:02:37+05:30\",\"agentId\":\"PT01PT01527118732216\",
  # \"billerId\":\"TSTV00000GUJ08\ ",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0112130660\",
  # \"amount\":\"300\",\"t xnDate\":\"2017-04- 17T12:29:37+05:30\",\"agentId\":\"KC01KC01INB519686490\",
  # \"billerId\":\"TSTU00000NAT0 7\",\"txnStatus\":\"REVERSAL\"},{\"txnReferenceId\":\"KC0119125677\",
  # \"amount\":\"9942 \",\"txnDate\":\"2017-04- 13T19:01:40+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTU00000NAT0 7\",\"txnStatus\":\"REVERSAL\"},{\"txnReferenceId\":\"KC0118125629\",\"amount\":\"1000 0\",\"txnDate\":\"2017-04- 13T18:24:43+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTW00000VSP0 9\",\"txnStatus\":\"REVERSAL\"},{\"txnReferenceId\":\"KC0117125559\",\"amount\":\"1000 0\",\"txnDate\":\"2017-04- 13T17:24:50+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTW00000VSP0 9\",\"txnStatus\":\"REVERSAL\"},{\"txnReferenceId\":\"KC0117125537\",\"amount\":\"1000 0\",\"txnDate\":\"2017-04- 13T17:12:18+05:30\",\"agentId\":\"KC01KC01BNK517435997\",\"billerId\":\"TSTW00000VSP 09\",\"txnStatus\":\"REVERSAL\"},{\"txnReferenceId\":\"KC0117125529\",\"amount\":\"100 00\",\"txnDate\":\"2017-04- 13T17:08:16+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTW00000VSP0 9\",\"txnStatus\":\"REVERSAL\"},{\"txnReferenceId\":\"KC0114125347\",\"amount\":\"100\ ",\"txnDate\":\"2017-04- 13T15:00:03+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0112125122\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 13T12:00:46+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0112123657\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 12T12:20:26+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0112123647\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 12T12:13:28+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0112123620\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 12T12:02:50+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0111123614\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 12T11:59:57+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0111123604\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 12T11:54:18+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0111123519\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 12T11:01:02+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KG0100030058\",\"amount\":\"100\",\ "txnDate\":\"2017-04-11T14:44:57+05:30\",\"agentId\":\"KG01KG01INB511371549\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KG0100030046\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 11T14:38:15+05:30\",\"agentId\":\"KG01KG01INB511371549\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0112122149\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 11T12:46:48+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"BN0119812225\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 11T10:20:16+05:30\",\"agentId\":\"BN01BN01INB514737554\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0116120890\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 10T16:17:33+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0112120681\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 10T13:00:27+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0112120660\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 10T12:44:28+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0112120649\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 10T12:37:20+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0112116366\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 07T12:27:02+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0111116325\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 07T11:39:46+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0111116302\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 07T11:12:54+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0118115633\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 06T18:46:32+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"KC0117115592\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 06T17:53:48+05:30\",\"agentId\":\"KC01KC01INB519686490\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0119111394\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 03T19:09:25+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0119111387\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 03T19:07:02+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0118111357\",\"amount\":\"100\",\ "txnDate\":\"2017-04- 03T18:47:33+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0118111350\",\"amount\":\"100\",\"txnDate\":\"2017-04- 03T18:41:16+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTV00000GUJ08 \",\"txnStatus\":\"SUCCESS\"},{\"txnReferenceId\":\"EQ0118111328\",\"amount\":\"50000\" ,\"txnDate\":\"2017-04- 03T18:26:55+05:30\",\"agentId\":\"EQ01EQ01INB511117329\",\"billerId\":\"TSTU00000NAT0 7\",\"txnStatus\":\"REVERSAL\"}]},\"customerDetails\":{\"name\":null,\"email\":null,\"mob ile\":\"9898990001\"},\"msgId\":\"COMPLAINTMSGEDE4F391A1F170609122217\",\"complai ntId\":null,\"openComplaint\":null,\"complaintStatus\":null,\"assigned\":null,\"responseCod e\":\"000\",\"responseReason\":\"SUCCESS\"}}|NA|NA|NA|NA|NA|NA|NA|NA|NA| NA|NA|NA|NA|NA|NA
  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_no, :agent_institution_id, :channel_id,
          :bbps_ref_id, :agent_id, :transaction_details,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
      ]
  )

  def message_code
    'B4000'
  end

  def complaint_type
    "O"
  end

  def order_number
    params[:order_number]
  end

  def self.handle_success(result)
    OpenStruct.new(
        {
            amount: result['response.parsed']['amount'],
            error_code: result['response.parsed']['error_code'],
            error_desc: result['response.parsed']['error_desc'],

        }
    )
  end

  def self.handle_error(data)
    data
  end

end