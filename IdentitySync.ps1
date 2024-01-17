
Param (
    [Parameter(Mandatory = $True, Position = 0)]
    [string]$RunMethod
)


Set-Location -Path $PSScriptRoot

Import-Module ".\domainADP.psm1" -Force
Import-Module ".\domainActiveDirectory.psm1" -Force

#Start-Transcript -Path C:\TestTranscript.txt #-Append



$SQLServer = "x.x.x.x"
# $SQLServer = "localhost"
$SQLDBName = "some-db"
$SQLDBUser = "sa"
$SQLDBPwd = "place-secret-password"


[string[]]$UserExceptions = Get-Content -Path '.\domain-User-Exceptions.txt'


$LogFilePath = "E:\Live\IDM\Logs\IdentitySync_Log_"

$CAT_INFO = "Info"

$updateRecords = 0
$updateCalls = 0

Function ScriptLog($cat, $line) {
    Write-Host (Get-Date).ToString() + " " + $cat + " " + $line
    $logfile = "$LogFilePath" + (Get-date -Format yyyy_MM_dd) + ".log"
    Add-Content $logfile ((Get-Date).ToString() + " " + $cat + " " + $line)
} 


$global:adp_data = @()



function ExecuteSqlQuery ($Server, $Database, $SQLDBUser, $SQLDBPwd, $SQLQuery) { 
    ScriptLog $CAT_INFO   "ExecuteSqlQuery started"

    #write-host values are: $Server, $Database, $SQLDBUser, $SQLDBPwd, $SQLQuery

    $Datatable = New-Object System.Data.DataTable       
    $Connection = New-Object System.Data.SQLClient.SQLConnection
    $connectionStr = "server='$Server';database='$Database';trusted_connection=true;" 
    if ($SQLDBUser -ne $null -and $SQLDBPwd -ne $null) {
        $connectionStr = "server='$Server';database='$Database';User ID='$SQLDBUser';Password='$SQLDBPwd'"
    }
    ScriptLog $CAT_INFO   "SQLQuery [$SQLQuery]"
    $Connection.ConnectionString = $connectionStr 

    $Connection.Open() 
    $Command = New-Object System.Data.SQLClient.SQLCommand 
    $Command.Connection = $Connection 
    $Command.CommandText = $SQLQuery 
    try {
        $Reader = $Command.ExecuteReader()     
        $Datatable.Load($Reader)
    } 
    catch {
        ScriptLog $CAT_ERROR  "$error"
        return($error)
    }
    $Connection.Close()       
    ScriptLog $CAT_INFO   "ExecuteSqlQuery completed successfully"
    return $Datatable 
}

function ConvertNULL ($ColValue) { 

    if ($ColValue -match ':\d\d:') {


        $ColValue = [datetime]$ColValue
        $ColValue = $ColValue.ToString("yyyy-MM-dd")
        write-host converted date: $ColValue
        #pause
        return $ColValue
        
        
    }
    elseif ($colvalue -match "'") {
        write-host before conversion: $colvalue
        $colvalue = $colvalue -replace "'", "''"
        write-host after conversion : $colvalue
        # pause
        return $colvalue
    }
    elseif ($ColValue -ne [System.DBNull]) {
        return "$ColValue";
    }
    
    elseif ($ColValue -eq "") {
        return "''";
    }
    
    return "NULL"
      
}

function getADPEmployeeInfo {
    param (
        $ADP_employeeID,
        [string]$ADP_associateOID,
        $worker,
        $ADPemployeeIDs,
        $workers,
        $DBrecord,
        $action

    )

    write-host action: $action
    Set-Location $PSScriptRoot


    # Skipping users with exceptions from domain-User-Exceptions.txt

    if ($UserExceptions -contains $ADP_associateOID) {
    
        ScriptLog $CAT_INFO  "User: $ADP_employeeID is in exceptions list. Skipping user..."

        continue
    }



    # Checking location code beforehand, to avoid generating UserDN, as it is an expensive operation.
    $dbLocationCode = convertNULL( $DBrecord.LocationCode )

    $adp_data = .\provision_domainADP_user_prod.ps1 -employeeID $ADP_employeeID -ADPassociateOID $ADP_associateOID -worker $worker -dbLocationCode  $dbLocationCode -action $action #| Tee-Object -Variable adp_data 


    $JobCode_original = $worker.workassignments.jobCode.codeValue

    # This removes duplicates in JobCode.
    if ($JobCode_original.count -gt 1) {
        
        $primaryIndicator = $worker.workassignments.primaryindicator

        if ($primaryIndicator.count -gt 1) {
            foreach ($indicator in $primaryIndicator) {
                if ($indicator -eq "true") {
                    $JCIndex = $primaryIndicator.IndexOf($indicator)
                    $JobCode = $JobCode_original[$JCIndex]
                    # pause
                }
            }

        }
      
    }
    else {
        $JobCode = $JobCode_original
    }
    




    # Replace JC with utility JC if it exists.

    $utilityJCs = 
    ("101GU41",
        "600GU15",
        "700GU18",
        "800GU35",
        "900GU38",
        "111GU36",
        "121GU58",
        "131GU60",
        "151GU146",
        "151GU64",
        "141GU132")

    $itemID = $worker.customfieldgroup.codefields.itemID
    $itemIDIndex = $itemID.IndexOf("1586553067349678_11")

    $utilityJCValue = $worker.customfieldgroup.codefields.codeValue[$itemIDIndex]
 
    if ($utilityJCValue) {

        $utilityJCValue_temp = $utilityJCValue
        $pos = $utilityJCValue_temp.IndexOf("-")
        $utilityJCValue = ($utilityJCValue_temp.Substring(0, $pos)).trim()
 
        if ($utilityJCs -like $JobCode) {

            
            ScriptLog $CAT_INFO   "Jobcode replaced for $ADP_employeeID from $Jobcode to $utilityjcvalue. "
            $JobCode = $utilityJCValue

        }

    }



    $staffid = $ADP_employeeID
    # $JobCodeLongName = $worker.workassignments.jobCode.longName
    # $JobCodeShortName = $worker.workassignments.jobCode.shortName
    # $OriginalHireDate = $worker.workerDates.originalHireDate
    # $HireDate = $worker.workassignments.HireDate
    
    # $PreferredName = $worker.person.PreferredName.givenname
    # $LegalNickName = $worker.person.legalName.nickname
    # $LegalFamilyName = $worker.person.legalName.familyName1

    $workerStatus = $worker.workerStatus.statusCode.codeValue
    $LegalGivenName = $worker.person.legalName.givenname
    $LegalMiddleName = $worker.person.legalName.MiddleName
    $LegalFormattedName = $worker.person.legalName.formattedName

    $MobileCountryDialing = $worker.person.communication.mobiles.countrydialing
    $MobileFormattedNumber = $worker.person.communication.mobiles.formattednumber
    

    if ($MobileFormattedNumber) {
    
        $Mobile = "+$MobileCountryDialing $MobileFormattedNumber"
    }

    $ADPUserStatus = $workerStatus
    
    if ($workerStatus -eq "Terminated") {
        $workerStatus = "Inactive"

    }

    #write-host assignment: $worker.workassignments.jobCode.codeValue
    #pause


    #write-host $adp_data
    # $LoginName, $AS400_OS_ID, $UPN , $UserDN, $StaffID, $EmployeeNumber, $EmployeeWorkerID, $EmployeeADPURL, $PrimaryEmail, $IPPhone, $Title, $Description, $LocationName, $LocationCode, $State, $Department, $DepartmentCode, $Division, $DivisionCode, $FirstName, $MiddleInitials, $LastName, $DisplayName, $ManagerLoginname , $ManagerDN = $adp_data

    $LoginName, $UserDN, $EmployeeNumber, $EmployeeADPURL, $PrimaryEmail, $IPPhone, $Title, $Description, $LocationName, $LocationCode, $State, $Department, $DepartmentCode, $Division, $DivisionCode, $FirstName, $LastName, $DisplayName, $EmployeeWorkerID, $manager_loginname = $adp_data
    
    $ManagerLoginName = $manager_loginname

    if ($JobCode_original.count -gt 1) {
   
        $Department = $worker.workAssignments[$JCIndex].assignedOrganizationalUnits.namecode.longName[0]
        if (!$Department) {
            $Department = $worker.workAssignments[$JCIndex].assignedOrganizationalUnits.namecode.shortname[0]
        }
        $DepartmentCode = $worker.workAssignments[$JCIndex].assignedOrganizationalUnits.namecode.codeValue[0]
        $Division = $worker.workAssignments[$JCIndex].assignedOrganizationalUnits.namecode.longName[1]
        if (!$Division) {
            $Division = $worker.workAssignments[$JCIndex].assignedOrganizationalUnits.namecode.shortname[1]
        }
        $DivisionCode = $worker.workAssignments[$JCIndex].assignedOrganizationalUnits.namecode.codeValue[1]
   
        $Title = $worker.WorkAssignments[$JCIndex].jobTitle
        $LocationName = $worker.workAssignments[$JCIndex].homeWorkLocation.nameCode.shortName
        $LocationCode = $worker.workAssignments[$JCIndex].homeWorkLocation.nameCode.codeValue
       

    }

    # Removing CN from DN - no longer required - passing basedn only. 
    # $UserDN_temp = $UserDN
    # $pos = $UserDN_temp.IndexOf(",")
    # $userDN = $UserDN_temp.Substring($pos + 1)


    # Gathering ROLE 
    $userobj = domaingetuser "employeeid" "$staffid"

    foreach ($member in $userobj.memberof) {

        if ($member -match "templates") {

            $memberobj = domainGetTemplatesGroup "distinguishedname" "$member"

            foreach ($group in $memberobj.memberof) {
            
                if (($group -match "FiservSignaturedomain01") -or ($group -match "FiservSignaturedomain02")) {

                    $role = [regex]::match($group, '- .([^/)]+?),').Groups[1].Value
                    # $role
              
                }

            }

        }

    }

    $dbRole = convertNULL( $DBrecord.Role )


    if ($role) {

        $ProvisionTarget = "CREATE_AS400"
        
    }
    elseif ($dbRole) {

        $ProvisionTarget = "DELETE_AS400"
        
    }
    else {
        
        # $ProvisionTarget = ""

    }

    # Formatting values 

    # $CN = "$FirstName $MiddleInitials $LastName"
    $comment = ""
    $company = "some company"
    $distinguishedName = $UserDN
    # $givenName = $FirstName
    # $initials = $MiddleInitials
    # $managerDN = $mgr_adp_data[3]
    # $name = "$FirstName $MiddleInitials $LastName"
    $proxyaddresses = "SIP:$LoginName@domain.net"
    # $samaccountname = $LoginName
    # $SN = $LastName
    # $ST = $State
    $UID = $EmployeeWorkerID
    $userprincipalname = "$LoginName@domain.net"
    $Organization = "domain"
        
    $RequestStatus = 0
    $ServicePickUp = 0
    $ServiceInstance = "NULL"
    $IsTopLeader = 0

    # Pick single value when there are multiple. 
    if ($Title.count -gt 1) {

        $Description = $Description[0]
        $LocationCode = $LocationCode[0]
        $EmployeeNumber = $EmployeeNumber[0]
        $Title = $Title[0]
        $LocationName = $LocationName[0]
    }
    # pause


    
    if (($ADPUserStatus -eq "Terminated") -or ($ADPUserStatus -eq "Inactive")) {
            
        # Set Terminated user dn to inactive ou.
        $distinguishedName = "OU=Inactive,DC=domain,DC=net"
        
        # Don't update terminated user's description
        # $Description = $dbDescription
    }



    #converting empty values to NULL

    # $LoginName = $LoginName -replace "''", ""
    # write-host loginname converted: $LoginName
    # pause
    # $AS400_OS_ID = convertNULL( $AS400_OS_ID )
    # $UPN = convertNULL( $UPN )
    # $JobCodeLongName = convertNULL( $JobCodeLongName )
    # $JobCodeShortName = convertNULL( $JobCodeShortName )
    # $OriginalHireDate = convertNULL( $OriginalHireDate )
    # $HireDate = convertNULL( $HireDate )
    # $PreferredName = convertNULL( $PreferredName )
    # $LegalNickName = convertNULL( $LegalNickName )
    # $LegalFamilyName = convertNULL( $LegalFamilyName )
    # $RequestStatus = convertNULL( $RequestStatus )
    # $CN = convertNULL( $CN )
    # $initials = convertNULL( $initials )
    # $managerDN = convertNULL( $managerDN )
    # $name = convertNULL( $name )
    # $SN = convertNULL( $SN )
    # $ST = convertNULL( $ST )
    # $givenName = convertNULL( $givenName )
    # $samaccountname = convertNULL( $samaccountname )
    
    $EmployeeWorkerID = convertNULL( $EmployeeWorkerID )
    $LoginName = convertNULL( $LoginName )
    $distinguishedName = convertNULL( $distinguishedName )
    $StaffID = convertNULL( $StaffID )
    $EmployeeNumber = convertNULL( $EmployeeNumber )
    $JobCode = convertNULL( $JobCode )
    $workerStatus = convertNULL( $workerStatus )
    $LegalGivenName = convertNULL( $LegalGivenName )
    $LegalMiddleName = convertNULL( $LegalMiddleName )
    $LegalFormattedName = convertNULL( $LegalFormattedName )
    $EmployeeADPURL = convertNULL( $EmployeeADPURL )
    $PrimaryEmail = convertNULL( $PrimaryEmail )
    $IPPhone = convertNULL( $IPPhone )
    $Title = convertNULL( $Title )
    $Description = convertNULL( $Description )
    $LocationName = convertNULL( $LocationName )
    $LocationCode = convertNULL( $LocationCode )
    $State = convertNULL( $State )
    $Department = convertNULL( $Department )
    $DepartmentCode = convertNULL( $DepartmentCode )
    $Division = convertNULL( $Division )
    $DivisionCode = convertNULL( $DivisionCode )
    $ServicePickUp = convertNULL( $ServicePickUp )
    $ManagerLoginName = convertNULL( $ManagerLoginName )
    $comment = convertNULL( $comment )
    $company = convertNULL( $company )
    $displayname = convertNULL( $displayname )
    $distinguishedName = convertNULL( $distinguishedName )
    $proxyaddresses = convertNULL( $proxyaddresses )
    $UID = convertNULL( $UID )
    $userprincipalname = convertNULL( $userprincipalname )
    $FirstName = convertNULL( $FirstName )
    $LastName = convertNULL( $LastName )
    $Organization = convertNULL( $Organization )
    $Mobile = convertNULL( $Mobile )
    $Role = convertNULL( $Role )
    $ProvisionTarget = convertNULL( $ProvisionTarget )
    $ADPUserStatus = convertNULL( $ADPUserStatus )


    # $dbAS400_OS_ID = convertNULL( $DBrecord.AS400_OS_ID )
    # $dbJobCodeLongName = convertNULL( $DBrecord.JobCodeLongName )
    # $dbJobCodeShortName = convertNULL( $DBrecord.JobCodeShortName )
    # $dbOriginalHireDate = convertNULL( $DBrecord.OriginalHireDate )
    # $dbHireDate = convertNULL( $DBrecord.HireDate )
    # $dbPreferredName = convertNULL( $DBrecord.PreferredName )
    # $dbLegalNickName = convertNULL( $DBrecord.LegalNickName )
    # $dbLegalFamilyName = convertNULL( $DBrecord.LegalFamilyName )
    #$dbRequestStatus = convertNULL( $DBrecord.RequestStatus )
    # $dbCN = convertNULL( $DBrecord.CN )
    # $dbgivenName = convertNULL( $DBrecord.givenName  )
    # $dbinitials = convertNULL( $DBrecord.initials  )
    # $dbmanagerDN = convertNULL( $DBrecord.managerDN  )
    # $dbname = convertNULL( $DBrecord.name  )
    # $dbsamaccountname = convertNULL( $DBrecord.samaccountname  )
    # $dbSN = convertNULL( $DBrecord.SN  )
    # $dbST = convertNULL( $DBrecord.ST  )
    

    $dbUPN = convertNULL( $DBrecord.UPN )    
    $dbEmployeeWorkerID = convertNULL( $DBrecord.EmployeeWorkerID )
    $dbLoginName = convertNULL( $DBrecord.LoginName )
    $dbUserDN = convertNULL( $DBrecord.UserDN )
    $dbStaffID = convertNULL( $DBrecord.StaffID )
    $dbEmployeeNumber = convertNULL( $DBrecord.EmployeeNumber )
    $dbJobCode = convertNULL( $DBrecord.JobCode )
    $dbworkerStatus = convertNULL( $DBrecord.userstatusvalue )
    $dbLegalGivenName = convertNULL( $DBrecord.LegalGivenName )
    $dbLegalMiddleName = convertNULL( $DBrecord.LegalMiddleName )
    $dbLegalFormattedName = convertNULL( $DBrecord.LegalFormattedName )
    $dbEmployeeADPURL = convertNULL( $DBrecord.EmployeeADPURL )
    $dbPrimaryEmail = convertNULL( $DBrecord.PrimaryEmail )
    $dbIPPhone = convertNULL( $DBrecord.IPPhone )
    $dbTitle = convertNULL( $DBrecord.Title )
    $dbDescription = convertNULL( $DBrecord.Description )
    $dbLocationName = convertNULL( $DBrecord.LocationName )
    $dbLocationCode = convertNULL( $DBrecord.LocationCode )
    $dbState = convertNULL( $DBrecord.State )
    $dbDepartment = convertNULL( $DBrecord.Department )
    $dbDepartmentCode = convertNULL( $DBrecord.DepartmentCode )
    $dbDivision = convertNULL( $DBrecord.Division )
    $dbDivisionCode = convertNULL( $DBrecord.DivisionCode )
    $dbServicePickUp = convertNULL( $DBrecord.ServicePickUp )
    $dbSupervisor = convertNULL( $DBrecord.SupervisorLoginName )
    $dbcomment = convertNULL( $DBrecord.comment  )
    $dbcompany = convertNULL( $DBrecord.company  )
    $dbdisplayname = convertNULL( $DBrecord.displayname  )
    $dbdistinguishedName = convertNULL( $DBrecord.distinguishedName  )
    $dbUID = convertNULL( $DBrecord.UID  )
    $dbproxyaddresses = convertNULL( $DBrecord.proxyaddresses  )
    $dbuserprincipalname = convertNULL( $DBrecord.userprincipalname )
    $dbFirstName = convertNULL( $DBrecord.FirstName )
    $dbLastName = convertNULL( $DBrecord.LastName )
    $dbOrganization = convertNULL( $DBrecord.OrganizationName )
    $dbMobile = convertNULL( $DBrecord.Mobile )
    $dbProvisionTarget = convertNULL( $DBrecord.ProvisionTarget )
    $dbADPUserStatus = convertNULL( $DBrecord.ADPUserStatus )
    


    $insertQuery = "

    
    INSERT INTO IdentityStore.[dbo].[identities]  (
    LoginName,
    StaffID,
    EmployeeNumber,
    JobCode,
    UserStatusValue,
    LegalGivenName,
    LegalMiddleName,
    LegalFormattedName,
    EmployeeADPURL,
    PrimaryEmail,
    IPPhone,
    Title,
    Description,
    LocationName,
    LocationCode,
    State,
    Department,
    DepartmentCode,
    Division,
    DivisionCode,
    RequestStatus,
    ServicePickUp,
    ServiceInstance,
    SupervisorLoginName,
    comment ,
    company ,
    displayname ,
    distinguishedName ,
    proxyaddresses ,
    UID ,
    userprincipalname,
    IsTopLeader,
    FirstName,
    LastName,
    OrganizationName,
    Mobile,
    Role,
    ProvisionTarget,
    ADPUserStatus
    
      )
    VALUES (
    '$LoginName',
    '$StaffID',
    '$EmployeeNumber',
    '$JobCode',
    '$workerStatus',
    '$LegalGivenName',
    '$LegalMiddleName',
    '$LegalFormattedName',
    '$EmployeeADPURL',
    '$PrimaryEmail',
    '$IPPhone',
    '$Title',
    '$Description',
    '$LocationName',
    '$LocationCode',
    '$State',
    '$Department',
    '$DepartmentCode',
    '$Division',
    '$DivisionCode',
    '$RequestStatus',
    '$ServicePickUp',
    '$ServiceInstance',
    '$ManagerLoginName',
    '$comment',
    '$company',
    '$displayname',
    '$distinguishedName',
    '$proxyaddresses',
    '$UID',
    '$userprincipalname',
    '$IsTopLeader',
    '$FirstName',
    '$LastName',
    '$Organization',
    '$Mobile',
    '$Role',
    '$ProvisionTarget',
    '$ADPUserStatus'

    
        )
        
        "
    
    if ($action -eq "insert") {



        # Write the provisioned email address BACK to ADP
        ScriptLog $CAT_INFO   "writing provisioned email address: $PrimaryEmail back to ADP entry for $ADP_associateOID"


        $certThumbprint = Get-domainADPCertificate
        $bearerToken = Get-domainADPBearerToken
        $Headers = @{ Authorization = "Bearer " + $bearerToken }
        Write-Host "Now writing provisioned email address: $PrimaryEmail back to ADP entry for $ADP_associateOID using bearerToken: $bearerToken" 
        $ADPbody = "{`"events`": [{`"data`": {`"eventContext`": {`"worker`":{`"associateOID`": `"$ADP_associateOID`"}},`"transform`":{`"worker`": {`"businessCommunication`":{`"email`":{`"emailUri`":`"$PrimaryEmail`"}}}}}}]}"
        try {
            $status = Invoke-RestMethod -Uri 'https://api.adp.com/events/hr/v1/worker.business-communication.email.change' -Method Post -ContentType 'application/json' -CertificateThumbprint $certThumbprint -Headers $Headers -Body $ADPbody -Verbose
            Write-Host "$($status.events.eventStatusCode.shortName)" -ForegroundColor Yellow
            ScriptLog $CAT_INFO   "Writing email back to ADP COMPLETED FOR $PrimaryEmail-->$ADP_associateOID"

        }
        catch {
            Write-Host "UPDATE FAILED FOR $PrimaryEmail-->$ADP_associateOID" -ForegroundColor Red
            ScriptLog $CAT_INFO   " Writing email back to ADP FAILED FOR $PrimaryEmail-->$ADP_associateOID"

        } 




        $insertQuery
        # pause
        ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $insertQuery
    }
    elseif ($action -eq "update") {


        $ADdistinguishedName = $userobj.distinguishedname
        
        if (($ADdistinguishedName -like "*HorizonVDI*") -or ($ADdistinguishedName -like "*Vendors*")) {

            # This skips updating user DN if user is in Vendors or HorizonVDI OU in AD.
            
            # This removes CN from DN.
            $distinguishedName = $ADdistinguishedName -replace '^.*?,(..=.*)$', '$1'
            ScriptLog $CAT_INFO   "User DN updation skipped. User DN in AD: $ADdistinguishedname "
        
        
            # ScriptLog $CAT_INFO   "AD User DN: $distinguishedName  "

        }
        else {

            # If location code doesn't change, skip updating user DN.
            # $distinguishedName = $dbdistinguishedName

        }


        if ($ADdistinguishedName -like "*PIMS*") {

            ScriptLog $CAT_INFO   "PIMS user. Update skipped. User DN in AD: $ADdistinguishedname "
            
            continue
        
        }

        if (($dbworkerStatus -eq "inactive") -and ($workerStatus -eq "inactive")) {

            ScriptLog $CAT_INFO   "Inactive user. Update skipped."
            
            continue
        }



        $updateQuery = "

        UPDATE IdentityStore.[dbo].[identities]
        SET 
        -- LoginName	 = '$LoginName',
        -- StaffID = '$StaffID',
        -- EmployeeNumber = '$EmployeeNumber',
        JobCode = '$JobCode',
        UserStatusValue = '$workerStatus',
        LegalGivenName = '$LegalGivenName',
        LegalMiddleName = '$LegalMiddleName',
        LegalFormattedName = '$LegalFormattedName',
        EmployeeADPURL = '$EmployeeADPURL',
        -- PrimaryEmail = '$PrimaryEmail',
        Title = '$Title',
        Description = '$Description',
        LocationName = '$LocationName',
        LocationCode = '$LocationCode',
        State = '$State',
        Department = '$Department',
        DepartmentCode = '$DepartmentCode',
        Division = '$Division',
        DivisionCode = '$DivisionCode',
        SupervisorLoginName = '$ManagerLoginName',
        comment  = '$comment',
        company  = '$company',
        displayname  = '$displayname',
        distinguishedName  = '$distinguishedName',
        -- proxyaddresses  = '$proxyaddresses',
        UID  = '$UID',
        -- userprincipalname = '$userprincipalname',
        FirstName = '$FirstName',
        LastName = '$LastName',
        OrganizationName = '$Organization',
        Mobile = '$Mobile',
        Role = '$Role',
        ProvisionTarget = '$ProvisionTarget',
        RequestStatus = '$RequestStatus',
        ServicePickUp = '$ServicePickUp',
        ServiceInstance = '$ServiceInstance',
        ADPUserStatus = '$ADPUserStatus'

        
        WHERE StaffID = $ADP_employeeID;
        "

        # if ($dbUPN -ne $UPN  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbUPN -ne $UPN  "; write-host "Data mismatch: db value: $dbUPN -ne $UPN  " }
        # if ($dbJobCodeLongName -ne $JobCodeLongName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbJobCodeLongName -ne $JobCodeLongName  "; write-host "Data mismatch: db value: $dbJobCodeLongName -ne $JobCodeLongName  " }
        # if ($dbJobCodeShortName -ne $JobCodeShortName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbJobCodeShortName -ne $JobCodeShortName  "; write-host "Data mismatch: db value: $dbJobCodeShortName -ne $JobCodeShortName  " }
        # if ($dbOriginalHireDate -ne $OriginalHireDate  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbOriginalHireDate -ne $OriginalHireDate  "; write-host "Data mismatch: db value: $dbOriginalHireDate -ne $OriginalHireDate  " }
        # if ($dbHireDate -ne $HireDate  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbHireDate -ne $HireDate  "; write-host "Data mismatch: db value: $dbHireDate -ne $HireDate  " }
        # if ($dbPreferredName -ne $PreferredName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbPreferredName -ne $PreferredName  "; write-host "Data mismatch: db value: $dbPreferredName -ne $PreferredName  " }
        # if ($dbLegalNickName -ne $LegalNickName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbLegalNickName -ne $LegalNickName  "; write-host "Data mismatch: db value: $dbLegalNickName -ne $LegalNickName  " }
        # if ($dbLegalFamilyName -ne $LegalFamilyName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbLegalFamilyName -ne $LegalFamilyName  "; write-host "Data mismatch: db value: $dbLegalFamilyName -ne $LegalFamilyName  " }
        # if ($dbCN -ne $CN  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbCN -ne $CN  "; write-host "Data mismatch: db value: $dbCN -ne $CN  " }
        # if ($dbgivenName -ne $givenName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbgivenName -ne $givenName  "; write-host "Data mismatch: db value: $dbgivenName -ne $givenName  " }
        # if ($dbinitials -ne $initials  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbinitials -ne $initials  "; write-host "Data mismatch: db value: $dbinitials -ne $initials  " }
        # if ($dbmanagerDN -ne $managerDN  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbmanagerDN -ne $managerDN  "; write-host "Data mismatch: db value: $dbmanagerDN -ne $managerDN  " }
        # if ($dbname -ne $name  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbname -ne $name  "; write-host "Data mismatch: db value: $dbname -ne $name  " }
        # if ($dbSN -ne $SN  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbSN -ne $SN  "; write-host "Data mismatch: db value: $dbSN -ne $SN  " }
        # if ($dbST -ne $ST  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbST -ne $ST  "; write-host "Data mismatch: db value: $dbST -ne $ST  " }
        
        ## if ($dbuserprincipalname -ne $userprincipalname ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbuserprincipalname -ne $userprincipalname "; write-host "Data mismatch: db value: $dbuserprincipalname -ne $userprincipalname " }
        
        # if ($dbEmployeeWorkerID -ne $EmployeeWorkerID  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbEmployeeWorkerID -ne $EmployeeWorkerID  "; write-host "Data mismatch: db value: $dbEmployeeWorkerID -ne $EmployeeWorkerID  " }
        if ($dbdistinguishedName -ne $distinguishedName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbdistinguishedName -ne $distinguishedName  "; write-host "Data mismatch: db value: $dbdistinguishedName -ne $distinguishedName  " }
        if ($dbJobCode -ne $JobCode  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbJobCode -ne $JobCode  "; write-host "Data mismatch: db value: $dbJobCode -ne $JobCode  " }
        if ($dbworkerStatus -ne $workerStatus  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbworkerStatus -ne $workerStatus  "; write-host "Data mismatch: db value: $dbworkerStatus -ne $workerStatus  " }
        if ($dbLegalGivenName -ne $LegalGivenName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbLegalGivenName -ne $LegalGivenName  "; write-host "Data mismatch: db value: $dbLegalGivenName -ne $LegalGivenName  " }
        if ($dbLegalMiddleName -ne $LegalMiddleName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbLegalMiddleName -ne $LegalMiddleName  "; write-host "Data mismatch: db value: $dbLegalMiddleName -ne $LegalMiddleName  " }
        if ($dbLegalFormattedName -ne $LegalFormattedName) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbLegalFormattedName -ne $LegalFormattedName"; write-host "Data mismatch: db value: $dbLegalFormattedName -ne $LegalFormattedName" }  
        if ($dbEmployeeADPURL -ne $EmployeeADPURL  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbEmployeeADPURL -ne $EmployeeADPURL  "; write-host "Data mismatch: db value: $dbEmployeeADPURL -ne $EmployeeADPURL  " }
        if ($dbTitle -ne $Title  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbTitle -ne $Title  "; write-host "Data mismatch: db value: $dbTitle -ne $Title  " }
        if ($dbDescription -ne $Description  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbDescription -ne $Description  "; write-host "Data mismatch: db value: $dbDescription -ne $Description  " }
        if ($dbLocationName -ne $LocationName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbLocationName -ne $LocationName  "; write-host "Data mismatch: db value: $dbLocationName -ne $LocationName  " }
        if ($dbLocationCode -ne $LocationCode  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbLocationCode -ne $LocationCode  "; write-host "Data mismatch: db value: $dbLocationCode -ne $LocationCode  " }
        if ($dbState -ne $State  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbState -ne $State  "; write-host "Data mismatch: db value: $dbState -ne $State  " }
        if ($dbDepartment -ne $Department  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbDepartment -ne $Department  "; write-host "Data mismatch: db value: $dbDepartment -ne $Department  " }
        if ($dbDepartmentCode -ne $DepartmentCode  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbDepartmentCode -ne $DepartmentCode  "; write-host "Data mismatch: db value: $dbDepartmentCode -ne $DepartmentCode  " }
        if ($dbDivision -ne $Division  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbDivision -ne $Division  "; write-host "Data mismatch: db value: $dbDivision -ne $Division  " }
        if ($dbDivisionCode -ne $DivisionCode  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbDivisionCode -ne $DivisionCode  "; write-host "Data mismatch: db value: $dbDivisionCode -ne $DivisionCode  " }
        if ($dbSupervisor -ne $ManagerLoginName  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbSupervisor -ne $ManagerLoginName  "; write-host "Data mismatch: db value: $dbSupervisor -ne $ManagerLoginName  " }
        if ($dbcomment -ne $comment  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbcomment -ne $comment  "; write-host "Data mismatch: db value: $dbcomment -ne $comment  " }
        if ($dbcompany -ne $company  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbcompany -ne $company  "; write-host "Data mismatch: db value: $dbcompany -ne $company  " }
        if ($dbdisplayname -ne $displayname  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbdisplayname -ne $displayname  "; write-host "Data mismatch: db value: $dbdisplayname -ne $displayname  " }
        if ($dbUID -ne $UID  ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbUID -ne $UID  "; write-host "Data mismatch: db value: $dbUID -ne $UID  " }
        if ($dbFirstName -ne $FirstName ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbFirstName -ne $FirstName "; write-host "Data mismatch: db value: $dbFirstName -ne $FirstName " }
        if ($dbLastName -ne $LastName ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbLastName -ne $LastName "; write-host "Data mismatch: db value: $dbLastName -ne $LastName " }
        if ($dbOrganization -ne $Organization ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbOrganization -ne $Organization "; write-host "Data mismatch: db value: $dbOrganization -ne $Organization " }
        if ($dbMobile -ne $Mobile ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbMobile -ne $Mobile "; write-host "Data mismatch: db value: $dbMobile -ne $Mobile  " }
        if ($dbRole -ne $Role ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbRole -ne $Role "; write-host "Data mismatch: db value: $dbRole -ne $Role  " }
        if ($dbProvisionTarget -ne $ProvisionTarget ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbProvisionTarget -ne $ProvisionTarget "; write-host "Data mismatch: db value: $dbProvisionTarget -ne $ProvisionTarget  " }
        if ($dbADPUserStatus -ne $ADPUserStatus ) { ScriptLog $CAT_INFO "Data mismatch: db value: $dbADPUserStatus -ne $ADPUserStatus "; write-host "Data mismatch: db value: $dbADPUserStatus -ne $ADPUserStatus  " }
			

    




        # pause

        if (

            ## $dbLoginName -ne $LoginName -OR 
            # $dbAS400_OS_ID -ne $AS400_OS_ID -OR 
            # $dbUPN -ne $UPN -OR 
            # $dbUserDN -ne $UserDN -OR 
            ## $dbStaffID -ne $StaffID -OR 
            # $dbJobCodeLongName -ne $JobCodeLongName -OR 
            # $dbJobCodeShortName -ne $JobCodeShortName -OR 
            # $dbOriginalHireDate -ne $OriginalHireDate -OR 
            # $dbHireDate -ne $HireDate -OR 
            # $dbPreferredName -ne $PreferredName -OR 
            # $dbLegalNickName -ne $LegalNickName -OR 
            ## $dbPrimaryEmail -ne $PrimaryEmail -OR 
            ## $dbIPPhone -ne $IPPhone -OR 
            # $dbCN -ne $CN -OR 
            # $dbgivenName -ne $givenName -OR 
            # $dbinitials -ne $initials -OR 
            # $dbmanagerDN -ne $managerDN -OR 
            # $dbname -ne $name -OR 
            # $dbproxyaddresses -ne $proxyaddresses -OR 
            # $dbsamaccountname -ne $samaccountname -OR 
            # $dbSN -ne $SN -OR 
            # $dbST -ne $ST -OR 
            ## $dbuserprincipalname -ne $userprincipalname -OR
            # $dbEmployeeWorkerID -ne $EmployeeWorkerID -OR 
            # $dbEmployeeNumber -ne $EmployeeNumber -OR 
            
            $dbdistinguishedName -ne $distinguishedName -OR 
            $dbUID -ne $UID -OR 
            $dbJobCode -ne $JobCode -OR 
            $dbworkerStatus -ne $workerStatus -OR 
            $dbLegalGivenName -ne $LegalGivenName -OR 
            $dbLegalMiddleName -ne $LegalMiddleName -OR 
            $dbLegalFamilyName -ne $LegalFamilyName -OR 
            $dbLegalFormattedName -ne $LegalFormattedName -OR 
            $dbEmployeeADPURL -ne $EmployeeADPURL -OR 
            $dbTitle -ne $Title -OR 
            $dbDescription -ne $Description -OR 
            $dbLocationName -ne $LocationName -OR 
            $dbLocationCode -ne $LocationCode -OR 
            $dbState -ne $State -OR 
            $dbDepartment -ne $Department -OR 
            $dbDepartmentCode -ne $DepartmentCode -OR 
            $dbDivision -ne $Division -OR 
            $dbDivisionCode -ne $DivisionCode -OR 
            $dbSupervisor -ne $ManagerLoginName -OR 
            $dbcomment -ne $comment -OR 
            $dbcompany -ne $company -OR 
            $dbdisplayname -ne $displayname -OR 
            $dbFirstName -ne $FirstName -OR
            $dbLastName -ne $LastName -OR
            $dbOrganization -ne $Organization -OR
            $dbMobile -ne $Mobile -OR
            $dbRole -ne $Role -OR
            $dbProvisionTarget -ne $ProvisionTarget -OR
            $dbADPUserStatus -ne $ADPUserStatus 


        ) {

        
       


            $updateQuery
            #write-host jobcode at update: $JobCode
            # pause
            
            ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $updateQuery
            $global:updateRecords++
            ScriptLog $CAT_INFO   "Update Records: $updateRecords"
            write-host "Update Records: $updateRecords"
            #pause
        }  

        
    }

}




function getADPEmployeeData {
    # $bearerToken = Get-domainADPBearerToken
    Write-Host "Gathering all ADP workers... standby." -ForegroundColor Magenta
    
    # Get-domainADPworkersEmployeeIDArrayList -bearerToken $bearerToken  #this gets all employee IDs and associateOIDs into $employeeIDworkerList collection.

    $bearerToken = Get-domainADPBearerToken
    Get-domainADPworkersArrayList -bearerToken $bearerToken  #this gets all workers JSON data into $workerList

    $employeeIDs = @{}

    foreach ($employee in $workerList) {
        if ($employee.workassignments.payrollFileNumber.count -gt 1) {
            $ADP_employeeID = ($employee.workAssignments | Where-Object { $_.primaryindicator -match "true" }).payrollfilenumber
        }
        else {
            $ADP_employeeID = $employee.workAssignments.payrollFileNumber #.Trim() # Get rid of all the trailing spaces
        }
	
        if ($ADP_employeeID -match '^[0]{2}') {
            $ADP_employeeID = $ADP_employeeID.Substring($ADP_employeeID.Length - 4)
        }
        else {
            $ADP_employeeID = $ADP_employeeID.Substring($ADP_employeeID.Length - 5)
        }
        #$ADP_employee_status = $employee.workerStatus.statusCode.codeValue
        $ADP_associateOID = $employee.associateOID
        
        $employeeIDs.add($ADP_employeeID, $ADP_associateOID)
        
    }

    return $employeeIDs, $workerList
}

# pause

$updateRecords = 0
$updateCalls = 0



function Update-JobCodeDB {
    param (
        $ADPID,
        $worker,
        $DBrecord, 
        $ChoiceType
    )

    $JC = $worker.workassignments.jobCode.codevalue
    $dbJC = $DBrecord.Jobcode
    $WS = $worker.workerStatus.statusCode.codeValue
    $dbADPWS = $DBrecord.ADPUserStatus
    $scheduledTime = (get-date).tostring("dd-MM-yyyy HH:mm:ss")
    $SID = $ADPID

    # Removing duplicate Jobcodes
    if ($JC.count -gt 1) {

        $terminationdate = $worker.workassignments.terminationdate
        if ($terminationdate[0] -eq $null) {
            
            $JC = $JC[0]

        }
        elseif (($terminationdate[0] -and $terminationdate[1]) -ne $null) {
            $JC = $JC[0]

        }
        
    }


    # Replace JC with utility JC if it exists.

    $utilityJCs = 
    ("101GU41",
        "600GU15",
        "700GU18",
        "800GU35",
        "900GU38",
        "111GU36",
        "121GU58",
        "131GU60",
        "151GU146",
        "151GU64",
        "141GU132")

    $itemID = $worker.customfieldgroup.codefields.itemID
    $itemIDIndex = $itemID.IndexOf("1586553067349678_11")

    $utilityJCValue = $worker.customfieldgroup.codefields.codeValue[$itemIDIndex]
 
    if ($utilityJCValue) {

        $utilityJCValue_temp = $utilityJCValue
        $pos = $utilityJCValue_temp.IndexOf("-")
        $utilityJCValue = ($utilityJCValue_temp.Substring(0, $pos)).trim()
 
        if ($utilityJCs -like $JC) {

            
            ScriptLog $CAT_INFO   "Jobcode replaced for $SID from $JC to $utilityjcvalue in JobCodeEmailRequests table. "
            $JC = $utilityJCValue

        }

    }


    if ($ChoiceType -eq "New") {

        $NewEntry = "

                Insert into IdentityStore.[dbo].JobCodeEmailRequests(
                NewJobCode,
                OldJobCode,
                SubmittedTime,
                RequestType,
                StaffID)
                
                values(

               '$JC',
                '',
                '$scheduledTime',
                'New',
                '$SID')
                
                "

        write-host $NewEntry
        ScriptLog $CAT_INFO   "$NewEntry"

        #pause

        ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $NewEntry
        return
    }
    elseif ($ChoiceType -eq "Update") {

        if ($dbADPWS -ne $WS) {

            if ($WS -eq "Active") {
    
                $NewEntry = "
    

                Insert into IdentityStore.[dbo].JobCodeEmailRequests
                    (
                    NewJobCode,
                    OldJobCode,
                    SubmittedTime,
                    RequestType,
                    StaffID
                    )
                    
                    values(
                    '$JC',
                    '',
                    '$scheduledTime',
                    'New',
                    '$SID')
                    "
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $NewEntry
                ScriptLog $CAT_INFO   "$NewEntry"
    
            }
            elseif ($WS -eq "Terminated") {
                $RemoveEntry = "
    
                Insert into IdentityStore.[dbo].JobCodeEmailRequests
                (
                    OldJobCode,
                    NewJobCode,
                SubmittedTime,
                RequestType,
                StaffID
                )
                
                values(
                   '$JC',
                    '',
                   '$scheduledTime',
                    'Remove',
                    '$SID'
                    )
                    "
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $RemoveEntry
                ScriptLog $CAT_INFO   " $RemoveEntry"

            }
    
    
        }
        elseif (($dbADPWS -and $WS) -eq "Active") {
            
            if ($JC -ne $dbJC) {

                $ChangeEntry = "
                
                Insert into IdentityStore.[dbo].JobCodeEmailRequests
                    (
                        OldJobCode,
                    NewJobCode,
                    SubmittedTime,
                    RequestType,
                    StaffID
                    )
                    
                    values(
                        '$dbJC',
                        '$JC',
                        '$scheduledTime',
                        'Change',
                        '$SID'
                        )
                        "
    
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $ChangeEntry
                ScriptLog $CAT_INFO   " $changeEntry"
                
            }
        }
    }

}
#pause

$updateRecords = 0
$updateCalls = 0

function Run-Code() {

    param (
        $command
    )

    foreach ($ADPID in $ADPemployeeIDs.Keys) {

        if ($command -eq "insert") {

            if (!($SQLDBData.StaffID -contains $ADPID)) {
                # $command = "insert"
                #write-host update sql db with staffid: $ADPID

                foreach ($worker in $workers) {

                    $AssoID = $ADPemployeeIDs.$ADPID
                    $workerAssoID = $worker.associateOID

                    if ($AssoID -eq $workerAssoID) {
                        #execute insert statement
                        write-host $ADPID
                        write-host $worker.associateOID
                        ScriptLog $CAT_INFO  "Sending $ADPID $assoID" 
                   
                        getADPEmployeeInfo $ADPID "$assoID" $worker $ADPemployeeIDs $workers $null $command 
                        # pause
                        #Send email for newuser
                        Update-JobCodeDB $ADPID $worker $DBrecord "New"
                        
                        ScriptLog $CAT_INFO   "New member : $adpid inserted."
                        # pause
                    }
                }

            } 
        }
        else {
            # $command = "update"
            foreach ($worker in $workers) {

                $AssoID = $ADPemployeeIDs.$ADPID
                $workerAssoID = $worker.associateOID

                if ($AssoID -eq $workerAssoID) {
                
                    foreach ($DBrecord in $SQLDBData) {
                        if ($DBrecord.StaffID -eq $ADPID) {
                            #write-host update id: $ADPID
                            # write-host update db-id: $DBrecord.StaffID
                            # ScriptLog $CAT_INFO  "Sending  $ADPID $assoID "


                            # pause
                            $updateCalls++
                            ScriptLog $CAT_INFO   "Call $updateCalls ; StaffID: $ADPID"
                            
                            getADPEmployeeInfo $ADPID "$assoID" $worker $ADPemployeeIDs $workers $DBrecord $command 
                            # pause
                       
                            Update-JobCodeDB $ADPID $worker $DBrecord "Update"
                            # pause
                        }
                    }
                }
            }
        }
    }
}



function ProcessDelta {
   
   

    ScriptLog $CAT_INFO   "Execution Method: $RunMethod"


    write-host "Starting Identity Sync."
    ScriptLog $CAT_INFO   "Starting Identity Sync."
    
    
    $bearerToken = Get-domainADPBearerToken


    $Headers = @{ Authorization = "Bearer " + $bearerToken
        Accept                  = "application/json;masked=false" 
    }
    
    # Get event.
    # $Event = Invoke-RestMethod "https://api.adp.com/core/v1/event-notification-messages" -Certificate $certADP -Headers $Headers -Verbose
    
    # Get database data.
    $SelectDBData = "SELECT * FROM [IdentityStore].[dbo].[identities] order by StaffID"
    $SQLDBData = ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $SelectDBData 
    
    
    do {

        $Event = Invoke-WebRequest "https://api.adp.com/core/v1/event-notification-messages" -Certificate $certADP -Headers $Headers -Verbose -UseBasicParsing #| Tee-Object -Variable EventVerbose 

        ScriptLog $CAT_INFO   "Event received: $Event"
        ScriptLog $CAT_INFO   "Event verbose: $Eventverbose"

    
        $EventContent = $Event.Content | Convertfrom-Json 

        $EventCode = $EventContent.events.eventNameCode.codeValue
    
        $associateOID = $EventContent.events.data.eventContext.worker.associateOID
        $associateOID_worker = $associateOID
        
        if (-Not $associateOID_worker) {
            
            $associateOID = $EventContent.events.data.eventContext.associateOID
            $associateOID_withoutworker = $associateOID
        }
        
        if (-Not $associateOID_withoutworker) {
            
            $associateOID = $EventContent.events.data.output.worker.associateOID

        }
        

        if ($associateOID) {


            
            if ($UserExceptions -contains $associateOID) {
    
                ScriptLog $CAT_INFO  "User associate ID: $associateOID is in exceptions list. Skipping user..."

                continue
                ScriptLog $CAT_INFO  "This should be skipped."
            }



    
            # Get worker
            $worker = Invoke-RestMethod "https://api.adp.com/hr/v2/workers/$associateOID" -Certificate $certADP -Headers $Headers -Verbose
     
    
            # update
    
            $employee = $worker.workers
    
            # Getting employeeid.
            if ($employee.workassignments.payrollFileNumber.count -gt 1) {
                $ADP_employeeID = ($employee.workAssignments | Where-Object { $_.primaryindicator -match "true" }).payrollfilenumber
            }
            else {
                $ADP_employeeID = $employee.workAssignments.payrollFileNumber #.Trim() # Get rid of all the trailing spaces
            }
	
            if ($ADP_employeeID -match '^[0]{2}') {
                $ADP_employeeID = $ADP_employeeID.Substring($ADP_employeeID.Length - 4)
            }
            else {
                $ADP_employeeID = $ADP_employeeID.Substring($ADP_employeeID.Length - 5)
            }
    
            if ($SQLDBData.EmployeeADPURL -match $associateOID) {

                foreach ($DBrecord in $SQLDBData) {

                    if ($DBrecord.staffid -eq $ADP_employeeID) {

                        getADPEmployeeInfo -ADP_employeeID $ADP_employeeID -ADP_associateOID "$associateOID" -worker $employee -DBrecord $DBrecord -action "update" 

                        Update-JobCodeDB -ADPID $ADP_employeeID -worker $employee -DBrecord $DBrecord -ChoiceType "Update"

                        $updateCalls++
                        ScriptLog $CAT_INFO   "Call $updateCalls ; StaffID: $ADP_employeeID"
                   

                    }
                }

        
                   

            }
            else {
    
                # insert

                if ( $EventCode -eq "worker.hire") {


                    getADPEmployeeInfo -ADP_employeeID $ADP_employeeID -ADP_associateOID "$associateOID" -worker $employee -action "insert" 
        
                    #Send email for newuser
                    Update-JobCodeDB -ADPID $ADP_employeeID -worker $employee -ChoiceType "New"
                        
                    ScriptLog $CAT_INFO   "New member : $ADP_employeeID inserted."
                    # pause
                }
            }
            # pause
            
        }
        
        # write-host deleting event?
        # Delete event 
        
        $adp_msg_msgid = $Event.Headers.'adp-msg-msgid'
        $uri = "https://api.adp.com/core/v1/event-notification-messages/$adp_msg_msgid"
            

        try {
            
            write-host delete?
            # pause

            $EventDelete = Invoke-WebRequest -Headers $headers -Method "DELETE" -Uri $uri -Certificate $certADP -UseBasicParsing
    
            $EventDelete
            ScriptLog $CAT_INFO   "Event Deleted : $EventDelete"
            ScriptLog $CAT_INFO   "Deleted Event adp_msg_msgid: $adp_msg_msgid"
            # pause

        }
        catch {
            ScriptLog $CAT_ERROR  "Error message: $error"
            break
            return($error)
        }
        
        # pause
        
    }until($Event.statusCode -eq 204)

    if ($Event.statusCode -eq 204) {

        ScriptLog $CAT_INFO   "Status Code: 204 : No new events."
        # pause

    }    
    

}


if ($RunMethod -eq "Full") {


    ScriptLog $CAT_INFO   "Execution Method: $RunMethod"


    write-host "Starting Identity Sync."
    ScriptLog $CAT_INFO   "Starting Identity Sync."
    

    #get all employees IDs from ADP
    ScriptLog $CAT_INFO  "Getting all employees IDs from ADP."
    $ADPemployeeIDs, $workers = getADPEmployeeData

    write-host ADP Employees count: $ADPemployeeIDs.count

    #get all employees IDs from SQL Database
    ScriptLog $CAT_INFO  "get all employees IDs from SQL Database"
    $SelectDBData = "SELECT * FROM [IdentityStore].[dbo].[identities] order by StaffID"
    

    $SQLDBData = ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $SelectDBData 


    # write-host ADP employees count: $workers.count
    # write-host ADP IDs count: $ADPemployeeIDs.count
    # write-host DB Employees Count: $SQLDBData.count
    # pause


    $updateRecords = 0
    $updateCalls = 0


    Run-Code "insert"

    # write-host insert completed
    # pause


    $updateRecords = 0
    $updateCalls = 0
    
    Run-Code "update"


}
elseif ($RunMethod -eq "Delta") {

    ProcessDelta
}


#Stop-Transcript