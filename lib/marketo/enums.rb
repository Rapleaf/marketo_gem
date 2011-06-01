module Rapleaf
  module Marketo
    # Types of operations you can do on a marketo list
    module ListOperationType
      ADD_TO       = 'ADDTOLIST'
      REMOVE_FROM  = 'REMOVEFROMLIST'
      IS_MEMBER_OF = 'ISMEMBEROFLIST'
    end

    # Types of keys that can be used to look up a lead
    module LeadKeyType
      IDNUM           = "IDNUM"
      COOKIE          = "COOKIE"
      EMAIL           = "EMAIL"
      LEADOWNEREMAIL  = "LEADOWNEREMAIL"
      SFDCACCOUNTID   = "SFDCACCOUNTID"
      SFDCCONTACTID   = "SFDCCONTACTID"
      SFDCLEADID      = "SFDCLEADID"
      SFDCLEADOWNERID = "SFDCLEADOWNERID"
      SFDCOPPTYID     = "SFDCOPPTYID"
    end
  end
end