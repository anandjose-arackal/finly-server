class CreateBankDetailsMasters < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_details_masters do |t|
      t.string :name
      t.string :ifsc_prefix
      t.timestamps
    end


    data = [
        {
            "name": "Abhyudaya Co-op Bank Ltd",
            "prefix": "ABHY"
        },
        {
            "name": "Abu Dhabi Commercial Bank Ltd",
            "prefix": "ADCB"
        },
        {
            "name": "National Bank of Abu Dhabi PJSC",
            "prefix": "NBAD"
        },
        {
            "name": "AB Bank Ltd.",
            "prefix": "ABBL"
        },
        {
            "name": "Ahmedabad Mercantile Co-op Bank",
            "prefix": "AMCB"
        },
        {
            "name": "Allahabad Bank",
            "prefix": "ALLA"
        },
        {
            "name": "Andhra Bank",
            "prefix": "ANDB"
        },
        {
            "name": "Antwerp Diamond Bank Mumbai",
            "prefix": "ADIA"
        },
        {
            "name": "Australia and New Zealand Banking Group Limited",
            "prefix": "ANZB"
        },
        {
            "name": "Axis Bank",
            "prefix": "UTIB"
        },
        {
            "name": "Bank Of America",
            "prefix": "BOFA"
        },
        {
            "name": "Bank Of Bahrain And Kuwait",
            "prefix": "BBKM"
        },
        {
            "name": "Bank of Baroda",
            "prefix": "BARB"
        },
        {
            "name": "Bank Of Ceylon",
            "prefix": "BCEY"
        },
        {
            "name": "Bank of India",
            "prefix": "BKID"
        },
        {
            "name": "Bank Of Maharashtra",
            "prefix": "MAHB"
        },
        {
            "name": "Bank Of Nova Scotia",
            "prefix": "NOSC"
        },
        {
            "name": "Bank Of Tokyo-Mitsubishi Ufj Ltd",
            "prefix": "BOTM"
        },
        {
            "name": "Bank Internasional Indonesia",
            "prefix": "IBBK"
        },
        {
            "name": "Barclays Bank Plc",
            "prefix": "BARC"
        },
        {
            "name": "Bassein Catholic Co-op Bank Ltd",
            "prefix": "BACB"
        },
        {
            "name": "Bharat Co-op Bank (Mumbai) Ltd",
            "prefix": "BCBM"
        },
        {
            "name": "BNP Paribas",
            "prefix": "BNPA"
        },
        {
            "name": "Canara Bank",
            "prefix": "CNRB"
        },
        {
            "name": "Catholic Syrian Bank Ltd",
            "prefix": "CSBK"
        },
        {
            "name": "Central Bank of India",
            "prefix": "CBIN"
        },
        {
            "name": "Chinatrust Commercial Bank",
            "prefix": "CTCB"
        },
        {
            "name": "Citibank India",
            "prefix": "CITI"
        },
        {
            "name": "Citizencredit Co-op Bank Ltd",
            "prefix": "CCBL"
        },
        {
            "name": "City Union Bank Ltd",
            "prefix": "CIUB"
        },
        {
            "name": "Corporation Bank",
            "prefix": "CORP"
        },
        {
            "name": "Cosmos Co-op Bank Ltd",
            "prefix": "COSB"
        },
        {
            "name": "Credit Agricole Corp and Investment Bank",
            "prefix": "CRLY"
        },
        {
            "name": "Commonwealth Bank of Australia",
            "prefix": "CTBA"
        },
        {
            "name": "DBS Bank",
            "prefix": "DBSS"
        },
        {
            "name": "Dena Bank",
            "prefix": "BKDN"
        },
        {
            "name": "Deutsche Bank Ag",
            "prefix": "DEUT"
        },
        {
            "name": "Development Credit Bank",
            "prefix": "DCBL"
        },
        {
            "name": "Dhanlaxmi Bank Ltd",
            "prefix": "DLXB"
        },
        {
            "name": "Dicgc",
            "prefix": "DICG"
        },
        {
            "name": "Doha Bank",
            "prefix": "DOHB"
        },
        {
            "name": "Dombivli Nagari Sahakari Bank Ltd",
            "prefix": "DNSB"
        },
        {
            "name": "Export-Import Bank of India",
            "prefix": "EIBI"
        },
        {
            "name": "Federal Bank Ltd",
            "prefix": "FDRL"
        },
        {
            "name": "Firstrand Bank Ltd",
            "prefix": "FIRN"
        },
        {
            "name": "Greater Bombay Co-op Bank Ltd",
            "prefix": "GBCB"
        },
        {
            "name": "HDFC Bank",
            "prefix": "HDFC"
        },
        {
            "name": "HSBC",
            "prefix": "HSBC"
        },
        {
            "name": "HSBC Bank Oman S.A.O.G.",
            "prefix": "OIBA"
        },
        {
            "name": "ICICI Bank",
            "prefix": "ICIC"
        },
        {
            "name": "IDBI Bank",
            "prefix": "IBKL"
        },
        {
            "name": "IDFC Bank Limited",
            "prefix": "IDFB"
        },
        {
            "name": "Indian Bank",
            "prefix": "IDIB"
        },
        {
            "name": "Indian Overseas Bank",
            "prefix": "IOBA"
        },
        {
            "name": "IndusInd Bank Ltd.",
            "prefix": "INDB"
        },
        {
            "name": "Industrial and Commercial Bank of China Ltd.",
            "prefix": "ICBK"
        },
        {
            "name": "ING Vysya Bank",
            "prefix": "VYSA"
        },
        {
            "name": "Industrial Bank of Korea",
            "prefix": "IBKO"
        },
        {
            "name": "Jammu & Kashmir Bank Ltd.",
            "prefix": "JAKA"
        },
        {
            "name": "Janakalyan Sahakari Bank Ltd",
            "prefix": "JSBL"
        },
        {
            "name": "Janata Sahkari Bank Ltd Pune",
            "prefix": "JSBP"
        },
        {
            "name": "Jpmorgan Chase Bank",
            "prefix": "CHAS"
        },
        {
            "name": "Kalupur Commercial Co-op Bank Ltd",
            "prefix": "KCCB"
        },
        {
            "name": "Kalyan Janata Sahakari Bank Ltd",
            "prefix": "KJSB"
        },
        {
            "name": "Kapole Co-op Bank",
            "prefix": "KCBL"
        },
        {
            "name": "Karnataka Bank Ltd.",
            "prefix": "KARB"
        },
        {
            "name": "Karnataka State Co-op Apex Bank",
            "prefix": "KSCB"
        },
        {
            "name": "Karur Vysya Bank",
            "prefix": "KVBL"
        },
        {
            "name": "Kotak Mahindra Bank",
            "prefix": "KKBK"
        },
        {
            "name": "KEB Hana Bank",
            "prefix": "KOEX"
        },
        {
            "name": "Krung Thai Bank PCL Mumbai",
            "prefix": "KRTH"
        },
        {
            "name": "Lakshmi Vilas Bank Ltd",
            "prefix": "LAVB"
        },
        {
            "name": "Mahanagar Co-op Bank Ltd",
            "prefix": "MCBL"
        },
        {
            "name": "Maharashtra State Co-operative Bank Limited",
            "prefix": "MSCI"
        },
        {
            "name": "Mashreq Bank Psc",
            "prefix": "MSHQ"
        },
        {
            "name": "Mehsana Urban Co-op Bank Ltd",
            "prefix": "MSNU"
        },
        {
            "name": "Mizuho Corporate Bank Ltd",
            "prefix": "MHCB"
        },
        {
            "name": "Nainital Bank Ltd",
            "prefix": "NTBL"
        },
        {
            "name": "National Australia Bank",
            "prefix": "NATA"
        },
        {
            "name": "New India Co-op Bank Ltd",
            "prefix": "NICB"
        },
        {
            "name": "Nkgsb Co-op Bank Ltd",
            "prefix": "NKGS"
        },
        {
            "name": "Nutan Nagarik Sahakari Bank Ltd",
            "prefix": "NNSB"
        },
        {
            "name": "Oman International Bank Saog",
            "prefix": "OIBA"
        },
        {
            "name": "Oriental Bank of Commerce",
            "prefix": "ORBC"
        },
        {
            "name": "Parsik Janata Sahakari Bank Ltd",
            "prefix": "PJSB"
        },
        {
            "name": "Punjab and Maharashtra Bank Ltd.",
            "prefix": "PMCB"
        },
        {
            "name": "Punjab National Bank",
            "prefix": "PUNB"
        },
        {
            "name": "Punjab & Sind Bank",
            "prefix": "PSIB"
        },
        {
            "name": "Qatar National Bank(QPSC)",
            "prefix": "QNBA"
        },
        {
            "name": "Rajkot Nagarik Sahakari Bank Ltd",
            "prefix": "RNSB"
        },
        {
            "name": "Ratnakar Bank Ltd",
            "prefix": "RATN"
        },
        {
            "name": "Reserve Bank Of India",
            "prefix": "RBIS"
        },
        {
            "name": "Royal bank of scotland",
            "prefix": "ABNA"
        },
        {
            "name": "Rabobank International",
            "prefix": "RABO"
        },
        {
            "name": "Sberbank",
            "prefix": "SABR"
        },
        {
            "name": "Saraswat Co-operative Bank Ltd.",
            "prefix": "SRCB"
        },
        {
            "name": "Shamrao Vithal Co-op Bank Ltd",
            "prefix": "SVCB"
        },
        {
            "name": "Shinhan Bank",
            "prefix": "SHBK"
        },
        {
            "name": "Societe Generale",
            "prefix": "SOGE"
        },
        {
            "name": "Sonali Bank Ltd.",
            "prefix": "BSON"
        },
        {
            "name": "South Indian Bank",
            "prefix": "SIBL"
        },
        {
            "name": "Standard Chartered Bank",
            "prefix": "SCBL"
        },
        {
            "name": "State Bank Of Bikaner And Jaipur",
            "prefix": "SBBJ"
        },
        {
            "name": "State Bank of Hyderabad",
            "prefix": "SBHY"
        },
        {
            "name": "State Bank of India",
            "prefix": "SBIN"
        },
        {
            "name": "SBI Global Factors Ltd(SBIGFL) factoring Unit",
            "prefix": "NBFC"
        },
        {
            "name": "India Factoring and Finance Solutions Pvt. Ltd",
            "prefix": "NBFC"
        },
        {
            "name": "IFCI Factors Limited",
            "prefix": "NBFC"
        },
        {
            "name": "Bombay Mercantile Co-operative bank Limited",
            "prefix": "BMCB"
        },
        {
            "name": "State Bank Of Mauritius Ltd",
            "prefix": "STCB"
        },
        {
            "name": "State Bank of Mysore",
            "prefix": "SBMY"
        },
        {
            "name": "State Bank Of Patiala",
            "prefix": "STBP"
        },
        {
            "name": "State Bank Of Travancore",
            "prefix": "SBTR"
        },
        {
            "name": "State Bank of Saurashtra",
            "prefix": "SSAU"
        },
        {
            "name": "Sumitomo Mitsui Banking Corporation",
            "prefix": "SMBC"
        },
        {
            "name": "Surat Peoples Co-op Bank Ltd",
            "prefix": "SPCB"
        },
        {
            "name": "Syndicate Bank",
            "prefix": "SYNB"
        },
        {
            "name": "Tamilnad Mercantile Bank Ltd",
            "prefix": "TMBL"
        },
        {
            "name": "Thane Janta Sahakari Bank, Ltd.",
            "prefix": "TJSB"
        },
        {
            "name": "The Karad Urban Co-op Bank Ltd",
            "prefix": "KUCB"
        },
        {
            "name": "The Nasik Merchants Co-op Bank Ltd",
            "prefix": "NMCB"
        },
        {
            "name": "UBS AG",
            "prefix": "UBSW"
        },
        {
            "name": "UCO Bank",
            "prefix": "UCBA"
        },
        {
            "name": "Union Bank of India",
            "prefix": "UBIN"
        },
        {
            "name": "United Bank of India",
            "prefix": "UTBI"
        },
        {
            "name": "United Overseas Bank",
            "prefix": "UOVB"
        },
        {
            "name": "Vijaya Bank",
            "prefix": "VIJB"
        },
        {
            "name": "West Bengal State Co-op Bank Ltd",
            "prefix": "WBSC"
        },
        {
            "name": "Westpac Banking Corporation",
            "prefix": "WPAC"
        },
        {
            "name": "Woori Bank",
            "prefix": "HVBK"
        },
        {
            "name": "Yes Bank",
            "prefix": "YESB"
        },
        {
            "name": "Emirates NBD Bank PJSC",
            "prefix": "EBIL"
        }
    ]


    data.each do |row|
      BankDetailsMaster.create(name: row[:"name"],ifsc_prefix: row[:"prefix"])
    end
  end
end
