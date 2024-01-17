
#Start-Transcript -Path C:\TestTranscript.txt #-Append

Set-Location -Path $PSScriptRoot
Import-Module ".\BGUActiveDirectory.psm1" -Force

$LogFilePath = "E:\Live\IDM\Logs\SendEmail_"

$CAT_INFO = "Info"

$SQLServer = "xx.xx.xx.xx"
$SQLDBName = "IdentityStore"
$SQLDBUser = "sa"
$SQLDBPwd = "place-sql-password"


write-host "Starting Email Script..."


Function ScriptLog($cat, $line) {
    Write-Host (Get-Date).ToString() + " " + $cat + " " + $line
    $logfile = "$LogFilePath" + (Get-date -Format yyyy_MM) + ".log"
    Add-Content $logfile ((Get-Date).ToString() + " " + $cat + " " + $line)
} 


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

function Send-Email {
    [CmdletBinding()]
    param (
        [Parameter()]
        $empIDobj,
        $Templates_group_obj,
        $ToMail,
        $staffID,
        $group,
        $JobCode,
        $action

    )
    
    $Username = "username@domain.com";
    $Password = 'secret-password';

    write-host "ToMail: $Tomail"

    
    
    if ($ToMail) {
        
        $Toemail = $ToMail
        [array]$ToeMail = $ToeMail.split(";") #original
        # [array]$Toemail = "my@domain.com"

        if (-Not $group) {

            write-host "Group Name is empty. Skipping sending email."
            ScriptLog $CAT_INFO   "Group Name is empty. Skipping sending email."

            continue
        }

    }
    else {
        
        write-host "To email is empty."
        ScriptLog $CAT_INFO   "To email is empty. Skipping sending email."

        continue
    }
    
    # Temporarily sending emails to IAM-BGU team, as requested.
    [array]$Toemail = "iam@domain.com"

   
    $message = new-object Net.Mail.MailMessage;
    $message.From = "orsus-iam@domain.com";
    # pause

    if ($action -eq "Add") {

        

        $ADdisplayName = $empIDobj.displayname
        $ADemployeeID = $staffid
        $ADsamAccountName = $empIDobj.samaccountname
        $ADemail = $empIDobj.mail
        $groupname = $group
        $templaterole = $Templates_group_obj.name
        $department = $empIDobj.department
        $jobtitle = $empIDobj.title
        $location = $empIDobj.l


        $New_htmlfile = $(Get-Content '.\create_from_template.htm')
        $message.Body = $ExecutionContext.InvokeCommand.ExpandString($New_htmlfile) # Set the message body from the HTML template

        $message.Subject = "NEW USER CREATION - $groupname";
         

    }

    if ($action -eq "Remove") {

        $ADdisplayName = $empIDobj.displayname
        $ADemployeeid = $staffID
        $ADsamAccountName = $empIDobj.samaccountname
        $ADemail = $empIDobj.mail
        $groupname = $group





        $Remove_htmlfile = $(Get-Content '.\termination.htm')
        $message.Body = $ExecutionContext.InvokeCommand.ExpandString($Remove_htmlfile) # Set the message body from the HTML template

        $message.Subject = "USER TERMINATION - $groupname";
         
    }

    if ($action -eq "ChangeAdd") {

        
        $user_description_name = $empIDobj.displayname
        $user_employeeid = $staffID
        $user_samaccountname = $empIDobj.samaccountname
        $user_email = $empIDobj.mail
        $new_department = $empIDobj.department
        $new_app_name = $group
        $new_template_name = $Templates_group_obj.name
        $new_app_role = $group
        # $effectivedate = $empIDobj.whencreated
        $effectivedate = (get-date).tostring("MM/dd/yyyy HH:mm:ss")


        # write-host $new_app_mailto,
        # write-host $user_description_name,
        # write-host $user_employeeid,
        # write-host $user_samaccountname,
        # write-host $user_email,
        # write-host $new_department,
        # write-host $new_app_name,
        # write-host $new_template_name,
        # write-host $new_app_role,
        # write-host $new_app_pimsinstallrequired,
        # write-host $effectivedate,
        # write-host $new_manager_mail
        # Pause


        $ChAdd_htmlfile = $(Get-Content '.\creation.htm')
        $message.Body = $ExecutionContext.InvokeCommand.ExpandString($ChAdd_htmlfile) # Set the message body from the HTML template

        $message.Subject = "ACCESS CREATION - $new_app_name";


    }

    if ($action -eq "ChangeRemove") {

        # Remove First
        $previous_app_mailto = $ToMail
        $user_description_name = $empIDobj.displayname
        $user_employeeid = $staffID
        $user_samaccountname = $empIDobj.samaccountname
        $user_email = $empIDobj.mail
        $previous_department = $empIDobj.department
        $previous_app_name = $group
        $previous_template_name = $Templates_group_obj.name
        $previous_app_role = $group
        # $effectivedate = $empIDobj.whencreated
        $effectivedate = (get-date).tostring("MM/dd/yyyy HH:mm:ss")

       
        # write-host $previous_app_mailto,
        # write-host $user_description_name,
        # write-host $user_employeeid,
        # write-host $user_samaccountname,
        # write-host $user_email,
        # write-host $previous_department,
        # write-host $previous_app_name,
        # write-host $previous_template_name,
        # write-host $previous_app_role,
        # write-host $effectivedate,
        # write-host $new_manager_mail
        
        # Pause


        $ChRemove_htmlfile = $(Get-Content '.\revocation.htm')
        $message.Body = $ExecutionContext.InvokeCommand.ExpandString($ChRemove_htmlfile) # Set the message body from the HTML template


        $message.Subject = " ACCESS REVOCATION - $previous_app_name";

    }

    if ($action -eq "HR") {

        [array]$ToEmail = "email@domain.com;email@domain.com;email@domain.com"

        $message.Body = "Hi HR, $jobcode doesn't have Template Group. Please create."
        $message.Subject = " NO TEMPLATE GROUP - for $jobcode";
        write-host mail sent to HR
        # pause

    }



    $smtp = new-object Net.Mail.SmtpClient("some.domain.net", "25");
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);

    $message.IsBodyHTML = $true

    # Adding CC for monitoring. Can be empty.
    $CCemails = "my@domain.com"

    [array]$CCemails = $CCemails.split(";") #original


    foreach ($mail in $ToEmail) {
        
        
        $message.To.clear() ;
        $message.CC.Clear();

        $message.To.Add($mail);
        
        foreach ($CCemail in $CCemails) {
            
            $message.Cc.Add($CCemail);

        }

        $smtp.send($message);
        
        write-host  $message.Subject
        
        write-host "Mail Sent" ; 
        ScriptLog $CAT_INFO   "Mail Sent."
        # pause
        $MSubject = $message.Subject
        $Mmail = $message.To
        ScriptLog $CAT_INFO   "Mail sent to: $Mmail"
        ScriptLog $CAT_INFO   "Mail sent to CC: $CCmails"
        ScriptLog $CAT_INFO   "Mail Subject: $Msubject"
    }



    # pause
}

function CreateMasterServiceNowIncident {
    param (
        [string]$employeeID,
        [string]$employee_loginID,
        [string]$employee_name,
        $action

    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    ####################################################
    # This section handles the credentials' decryption
    ####################################################
    $credsfile = ".\SN_ReST_creds.txt"
    $keyfile = ".\SN_REST.key"
    $credsstring = Get-Content $credsfile
    $key = Get-Content $keyfile
    $securestring = ConvertTo-SecureString -string $credsstring -Key $key
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securestring)
    $credentials = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    $username, $password = $credentials -split ":"

    # Get the username and password and set to Base64 to pass in the header
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

    # Set proper headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('Authorization', ('Basic {0}' -f $base64AuthInfo))
    $headers.Add('Accept', 'application/json')

    $uri = "https://domain.service-now.com/api/now/table/incident"

    $method = "POST"

    if ($action -eq "new") {

        $short_description = "MASTER TICKET - PROVISION: USER ACCESS - $employee_name (EmployeeID: $employeeID)"
    
    }
    
    if ($action -eq "remove") {
    
        $short_description = "MASTER TICKET - DEPROVISION: USER ACCESS TERMINATION - $employee_name (EmployeeID: $employeeID)"
    
    }
    if ($action -eq "Change") {
    
        $short_description = "MASTER TICKET - USER ROLE CHANGE - $employee_name (EmployeeID: $employeeID)"
    
    }

    # If NO Master ticket is passed, then create one
    $body = @{   #Create body of the POST request
        assignment_group       = "InfoSecIAM"# <--info attribute on the group object
        # short_description      = "MASTER TICKET - DEPROVISION: USER ACCESS TERMINATION - $employee_name (EmployeeID: $employeeID)"
        short_description      = $short_description
        comments_and_worknotes = "Please see that this is closed ASAP."
        caller_id              = "$employee_loginID"
        comment                = ""
        priority               = "2"
        opened_by              = "InfoSecIAMAdmin"
    }

    $bodyJson = $body | ConvertTo-Json

    # Send HTTP request
    $create_response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $bodyJson -ContentType 'application/json' -UseBasicParsing
    # Print response
    $ticket = $create_response | ConvertFrom-Json

    $ticket_information = $($ticket.result)

    #    $incident_ticket = $($ticket.result.number)
    #    $assignment_group = $($ticket.result.assignment_group)
    #    $master_incident_ticket_sys_id = $($ticket.result.sys_id)
    return $ticket_information
}


function CreateServiceNowIncident {
    param (
        # [Parameter(Mandatory = $True, Position = 0)]
        
        [string]$master_incident,
        [string]$assignment_group,
        [string]$employee_name,
        [string]$employeeID,
        [string]$employee_loginID,
        [string]$employee_email,
        [string]$application_name,
        [string]$application_role,
        [string]$ServiceNowAssignmentGroup,
        [string]$action
    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    ####################################################
    # This section handles the credentials' decryption
    ####################################################
    $credsfile = ".\SN_ReST_creds.txt"
    $keyfile = ".\SN_REST.key"
    $credsstring = Get-Content $credsfile
    $key = Get-Content $keyfile
    $securestring = ConvertTo-SecureString -string $credsstring -Key $key
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securestring)
    $credentials = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    $username, $password = $credentials -split ":"


    # Get the username and password and set to Base64 to pass in the header
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))
    # $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

    # Set proper headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String], [String]]"
    $headers.Add('Authorization', ('Basic {0}' -f $base64AuthInfo))
    $headers.Add('Accept', 'application/json')

    $uri = "https://domain.service-now.com/api/now/table/incident"

    $method = "POST"
    # $master_incident = "INC0182847"
    
    # if(-Not $ServiceNowAssignmentGroup){

    #     $assignment_group  = "InfoSecIAM"

    # }
    
    if ($action -eq "new") {

        $short_description = "PROVISION: USER ACCESS - $application_name"
        $workNotes = "Please provision access for $employee_name `n`nEmail: $employee_email`n`tEmployeeID: $employeeID`n`tBGULoginID: $employee_loginID`nApplication Role: $application_role"
    
    }
    
    if ($action -eq "remove") {
    
        $short_description = "DEPROVISION: USER ACCESS TERMINATION - $application_name"
        $workNotes = "Please revoke/terminate access for $employee_name `n`nEmail: $employee_email`n`tEmployeeID: $employeeID`n`tBGULoginID: $employee_loginID`nApplication Role: $application_role"
    
    }


    # assignment_group = "$ServiceNowAssignmentGroup" # <--info attribute on the group object
    # short_description = "DEPROVISION: USER ACCESS TERMINATION - $application_name"

    # If NO Master ticket is passed, then create one
    $body = @{   #Create body of the POST request
        
        assignment_group  = "InfoSecIAM" 
        short_description = "$short_description"
        caller_id         = "$employee_loginID"
        comments          = "IMPORTANT INSTRUCTIONS`n`nPer compliance requirements, this MUST be completed and resolved within 1 business day`n`nTo resolve this incident, you MUST ATTACH A SCREENSHOT as proof of action."
        work_notes        = "$workNotes"
        parent            = "$master_incident"
        parent_incident   = "$master_incident"
        priority          = "2"
        opened_by         = "InfoSecIAMAdmin"
    }

    $bodyJson = $body | ConvertTo-Json

    # Send HTTP request
    $create_response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $bodyJson -ContentType 'application/json' -UseBasicParsing
    # Print response
    $ticket = $create_response | ConvertFrom-Json

    $ticket_information = $($ticket.result)

    $incident_ticket = $($ticket.result.number)
    $assignment_group = $($ticket.result.assignment_group)
    # $master_incident_ticket_sys_id = $($ticket.result.sys_id)

    Write-Host "Incident ticket $incident_ticket created and assigned to $assignment_group"
    ScriptLog $CAT_INFO   "Incident ticket $incident_ticket created and assigned to $assignment_group"
        
    return $ticket_information
}


function Process-JobCodes {
    param (
        $Option
    )
    

    if ($Option -eq "New") {

    
        $NewStaffIDQuery = "   select staffid from identitystore..jobcodeemailrequests where requesttype = 'new' and status IS NULL   "
        $NewJCQuery = "    select newjobcode from identitystore..jobcodeemailrequests where requesttype = 'new' and status IS NULL  "

        [array]$newstaffids = ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $NewStaffIDQuery |   Select-Object staffid -ExpandProperty staffid # -first 2
        [array]$newJCs = ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $NewJCQuery | select-object newjobcode -ExpandProperty newjobcode # -first 2


        # write-host  $newstaffids
        # write-host  $newJCs
        # pause

        ScriptLog $CAT_INFO   "Processing StaffIDs: $newstaffids"
        ScriptLog $CAT_INFO   "Processing JobCodes: $newJCs"


        for ($i = 0; $i -lt $newstaffids.Count; $i++) {

            [string]$newstaffid = $newstaffids[$i]
            $NewempIDobj = BGUGetUser "employeeid" $newstaffid

            # This checks if New employee exists in AD.
            if ($NewempIDobj) {

               
                $StartedTime = (get-date).tostring("dd-MM-yyyy HH:mm:ss")
                $currStatus = "Initiated"
                $NewstartedtimeQuery = "    update identitystore..jobcodeemailrequests set startedtime = '$startedtime', Status='$currStatus' , ResultDetails='' where staffid = '$newstaffid' "
                # ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $NewstartedtimeQuery 
                
                
                $newJC = $NewJCs[$i]

                ScriptLog $CAT_INFO   "New user Process Initiated for $newstaffid - $newJC."
                write-host this is JC : $newJC
                # pause
                $Templates_group_obj = BGUGetTemplatesGroup "description" "*$newJC*" 


                # If Template group not found, send email to HR.
                if (-Not $Templates_group_obj) {
                    
                    $HRMail = "HR@domain.com"

                    ScriptLog $CAT_INFO   "Sending Email to HR."

                    Send-Email -JobCode $newJC -action "HR"




                    $TemplateNotFoundQuery = "    update identitystore..jobcodeemailrequests set ResultDetails='Template Group not found for $newJC.' where staffid='$newstaffid' "
                    ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $TemplateNotFoundQuery 
    
                    ScriptLog $CAT_INFO   "Template Group not found for $newJC."
                    continue
                }





                $ADdisplayName = $NewempIDobj.displayname
                $ADsamAccountName = $NewempIDobj.samaccountname
                $ADemail = $NewempIDobj.mail
                $Newtemplaterole = $Templates_group_obj.name

                #Create Master ticket for this user $newstaffid
                write-host $newstaffid $ADsamAccountName $ADdisplayName
                $NewMasterTicket = CreateMasterServiceNowIncident $newstaffid $ADsamAccountName $ADdisplayName "New"
                $NewMasterTicket = $NewMasterTicket.number 
                write-host masterticket: $NewMasterTicket
                # pause

                foreach ($member in $Templates_group_obj.memberof) {

                    $mem_obj = BGUGetApplicationsgroup "distinguishedname" "$member"

                    $newMail = $mem_obj.mail
                    $newgroup = $mem_obj.name

                    # Get ServiceNow Assignment group from Group's Notes attribute.
                    $NewgroupNotes = $mem_obj.notes
                    write-host NewgroupNotes: $NewgroupNotes
                    $NewgroupNotes_temp = $NewgroupNotes
                    $pos = $NewgroupNotes_temp.IndexOf(":")
                    $NewServiceNowAssignmentGroup = $NewgroupNotes_temp.Substring($pos + 1)
                    write-host  "NewServiceNowAssignmentGroup : $NewServiceNowAssignmentGroup"
                    write-host member: $member
                    write-host mail: $newMail
                    write-host group: $newgroup
                    # ScriptLog $CAT_INFO   "Sending mail to $newMail - $newgroup."


                    # $groupname = $newgroup
                    # $templaterole = $Templates_group_obj.name
                    # $department = $empIDobj.department
                    # $jobtitle = $empIDobj.title
                    # $location = $empIDobj.l

                    # write-host $ADdisplayName,
                    # write-host $ADemployeeID,
                    # write-host $ADsamAccountName
                    # write-host $ADemail,
                    # write-host $groupname,
                    # write-host $templaterole,   
                    # write-host $department,
                    # write-host $jobtitle,    
                    # write-host $location
                    # pause

                    if (-not $newMail) {

                        $newMail = "iam@domain.com"
                    }

                    ScriptLog $CAT_INFO   "Sending New User process values: $newMail, $newstaffid, $newgroup."
                    Send-Email -empIDobj $NewempIDobj -Templates_group_obj $Templates_group_obj -ToMail $newMail -staffID $newstaffid -group $newgroup -action "Add"

                    # $TicketObj = CreateServiceNowIncident $newgroup $ADdisplayName $newstaffid $ADsamAccountName $ADemail $newgroup $templaterole "new"
                    $TicketObj = CreateServiceNowIncident -master_incident $NewMasterTicket -assignment_group $newgroup -employee_name $ADdisplayName -employeeID $newstaffid -employee_loginID $ADsamAccountName -employee_email $ADemail -application_name $newgroup -application_role $Newtemplaterole -ServiceNowAssignmentGroup $NewServiceNowAssignmentGroup -action "New"

                    $TicketObj = $TicketObj.number
                    write-host  New ticket number: $TicketObj

                    # pause
                }
                
                #Record status in database.
                $Newcompletedtime = (get-date).tostring("dd-MM-yyyy HH:mm:ss")
                $currStatus = "Completed"
                $NewcompletedtimeQuery = "    update identitystore..jobcodeemailrequests set completedtime = '$newcompletedtime', Status='$currStatus' , ResultDetails='' where staffid='$newstaffid' and status IS NULL "
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $NewcompletedtimeQuery 

                ScriptLog $CAT_INFO   "New user Process completed."
            
            }
            else {

                $currStatus = "$newstaffid does not exist in AD yet."
                $NewErrorQuery = "    update identitystore..jobcodeemailrequests set ResultDetails='$currStatus' where staffid='$newstaffid' and status IS NULL "
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $NewErrorQuery 

                write-host "$newstaffid does not exist in AD yet."
                ScriptLog $CAT_INFO   "$newstaffid does not exist in AD yet."
            }
        }

    }

    if ($Option -eq "Remove") {




        $RemoveStaffIDQuery = "    select staffid from identitystore..jobcodeemailrequests where requesttype = 'remove' and status IS NULL  "
        $RemoveJCQuery = "    select oldjobcode from identitystore..jobcodeemailrequests where requesttype = 'Remove' and status IS NULL  "

        [array]$Removestaffids = ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $RemoveStaffIDQuery |   Select-Object staffid -ExpandProperty staffid # -first 2
        [array]$RemoveJCs = ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $RemoveJCQuery | select-object oldjobcode -ExpandProperty oldjobcode # -first 2


        write-host  $removestaffids
        write-host  $removeJCs
        # pause

        ScriptLog $CAT_INFO   "User remove values: $removestaffids - $removeJCs "


        for ($i = 0; $i -lt $removestaffids.Count; $i++) {

            [string]$removestaffid = $removestaffids[$i]
            $RemoveEmpIDobj = BGUGetUser "employeeid" $removestaffid
           

            if ( $RemoveEmpIDobj.distinguishedname -like "*OU=Inactive,DC=bgu,DC=net*") {
                #Original

                # if ((-Not $RemoveEmpIDobj) -or ($RemoveEmpIDobj.distinguishedname -like "*OU=Inactive,OU=TESTING-OU,DC=bgu,DC=net*")) {
                
                $StartedTime = (get-date).tostring("dd-MM-yyyy HH:mm:ss")
                $currStatus = "Initiated"
                $removestartedtimeQuery = "    update identitystore..jobcodeemailrequests set startedtime = '$startedtime', Status='$currStatus' , ResultDetails=''  where staffid='$removestaffid' "
                # ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $removestartedtimeQuery 
    
                $removeJC = $removeJCs[$i]
            
                ScriptLog $CAT_INFO   "User remove process started for: $removestaffid - $removeJC. "

                $Templates_group_obj = BGUGetTemplatesGroup "description" "*$removeJC*"


                $ADdisplayName = $RemoveEmpIDobj.displayname
                $ADemployeeid = $removestaffid
                $ADsamAccountName = $RemoveEmpIDobj.samaccountname
                $ADemail = $RemoveEmpIDobj.mail
                $Removetemplaterole = $Templates_group_obj.name


                #Create Master ticket for this user $removestaffid
                write-host $removestaffid $ADsamAccountName $ADdisplayName
                $RemoveMasterTicket = CreateMasterServiceNowIncident $removestaffid $ADsamAccountName $ADdisplayName
                # $RemoveMasterTicket = CreateMasterServiceNowIncident "1551" "bolognaa" "Bologna, Antonio A" # Example
                $RemoveMasterTicket = $RemoveMasterTicket.number 
                write-host masterticket: $Removemasterticket
                # pause


                foreach ($member in $Templates_group_obj.memberof) {
                
                    write-host this is staffid: $removestaffid

                  
                    $mem_obj = BGUGetApplicationsGroup "distinguishedname" $member
                    $removeMail = $mem_obj.mail
                    $removegroup = $mem_obj.name

                    $removegroupNotes = $mem_obj.notes
                    write-host removegroupnotes: $removegroupNotes
                    $removegroupNotes_temp = $removegroupNotes
                    $pos = $removegroupNotes_temp.IndexOf(":")
                    $RemoveServiceNowAssignmentGroup = $removegroupNotes_temp.Substring($pos + 1)
                    write-host  "RemoveServiceNowAssignmentGroup : $RemoveServiceNowAssignmentGroup"
                    write-host member: $member
                
                    
                    if ($removemail) {
                        
                        ScriptLog $CAT_INFO   "User remove process values: $removeMail $removestaffid $removegroup. "
                        Send-Email -empIDobj $RemoveEmpIDobj -Templates_group_obj $Templates_group_obj -ToMail $removeMail -staffID $removestaffid -group $removegroup -action "remove"
                        write-host remove values: $RemoveMasterTicket $removegroup $ADdisplayName $removestaffid $ADsamAccountName $ADemail $removegroup $Removetemplaterole $RemoveServiceNowAssignmentGroup "remove"
                        $TicketObj = CreateServiceNowIncident -master_incident $RemoveMasterTicket -assignment_group $removegroup -employee_name $ADdisplayName -employeeID $removestaffid -employee_loginID $ADsamAccountName -employee_email $ADemail -application_name $removegroup -application_role $Removetemplaterole -ServiceNowAssignmentGroup $RemoveServiceNowAssignmentGroup -action "remove"
    
                        $TicketObj = $TicketObj.number
                        write-host  Remove ticket number: $TicketObj
                        # pause
                    }
                    
                    #Record status in database.
                    


                    #pause
                }

                $removecompletedtime = (get-date).tostring("dd-MM-yyyy HH:mm:ss")
                $currStatus = "Completed"
                $removecompletedtimeQuery = "    update identitystore..jobcodeemailrequests set completedtime = '$removecompletedtime', Status='$currStatus' , ResultDetails='' where staffid='$removestaffid' and status IS NULL"
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $removecompletedtimeQuery 

                ScriptLog $CAT_INFO   "User remove process completed. "
            
                # Generating description for Inactive user.
                
                $UserTitle = $RemoveEmpIDobj.title
                $datevalue = (get-date).ToString("dd/MM/yyyy HH:mm:ss")
                $UserDescription = "INACTIVE - $UserTitle - TERMINATED [$datevalue ChST] - ServiceNow MasterIncident: $Removemasterticket"

                
                # Update description for Inactive users in IDENTITIES 

                $UserDescriptionQuery = " update identitystore..IDENTITIES set description='$UserDescription',
                RequestStatus = '0',
                ServicePickUp = '0',
                ServiceInstance = 'NULL'
                
                where staffid='$removestaffid'"
                # $UserDescriptionQuery 
                # pause
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $UserDescriptionQuery 

                ScriptLog $CAT_INFO   "User description updated in IDENTITIES. "

                # pause



            }
            else {

                $currStatus = "$removestaffid not yet removed from AD."
                $RemoveErrorQuery = "    update identitystore..jobcodeemailrequests set ResultDetails='$currStatus' where staffid='$removestaffid' and status IS NULL "
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $RemoveErrorQuery 

                write-host "$removestaffid not yet removed from AD."
                ScriptLog $CAT_INFO   "$removestaffid not yet removed from AD."
            }
        }

    }

    if ($Option -eq "Change") {
    
        $changeStaffIDsQuery = "   select staffid from identitystore..jobcodeemailrequests where requesttype = 'change' and status IS NULL  "
        $NewChangeQuery = "    select newjobcode from identitystore..jobcodeemailrequests where requesttype = 'change' and status IS NULL "
        $RemoveChangeQuery = "    select oldjobcode from identitystore..jobcodeemailrequests where requesttype = 'change' and status IS NULL  "

        [array]$NewJobCodes = ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $NewChangeQuery | select-object newjobcode -ExpandProperty newjobcode # -first 1
        [array]$RemoveJobCodes = ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $RemoveChangeQuery | select-object oldjobcode -ExpandProperty oldjobcode # -first 1
        [array]$ChangeStaffIDs = ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $ChangestaffidsQuery | select-object staffid -ExpandProperty staffid # -first 1

        for ($i = 0; $i -lt $changestaffids.Count; $i++) {

            [string]$changestaffid = $ChangeStaffIDs[$i]


            $StartedTime = (get-date).tostring("dd-MM-yyyy HH:mm:ss")
            $currStatus = "Initiated"
            $changestartedtimeQuery = "    update identitystore..jobcodeemailrequests set startedtime = '$startedtime', Status='$currStatus' , ResultDetails='' where staffid = '$changestaffid' "
            # ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $changestartedtimeQuery 
    
            write-host "Process Initiated."
            
            $newjobcode = $Newjobcodes[$i]
            $removejobcode = $Removejobcodes[$i]
            ScriptLog $CAT_INFO   "User change process initiated for: $changestaffid - new: $newjobcode - old: $removejobcode "

            # write-host staffid: $changestaffid
            # write-host staffid: $newjobcode
            # write-host staffid: $removejobcode
            # pause

            $Templates_new_group_obj = BGUGetTemplatesGroup "description" "*$newjobcode*" 
            $Templates_remove_group_obj = BGUGetTemplatesGroup "description" "*$removejobcode*" 

            # $Templates_new_group_obj = BGUGetTemplatesGroup "description" "*100GU16*"
            # $Templates_REMOVE_group_obj = BGUGetTemplatesGroup "description" "*181SF02*"



            # If Template group not found, send email to HR.
            if (-Not $Templates_new_group_obj) {
                    
                ScriptLog $CAT_INFO   "Sending Email to HR."

                Send-Email -JobCode $newjobcode -action "HR"

                $TemplateNotFoundQuery = "    update identitystore..jobcodeemailrequests set  ResultDetails='Template Group not found for $newjobcode.' where staffid='$newjobcode' "
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $TemplateNotFoundQuery 
    
                ScriptLog $CAT_INFO   "Template Group not found for $newjobcode."
                # pause
                continue
            }






            $ChangeEmpIDobj = BGUGetUser "employeeid" $changestaffid
            $ChangeNewTemplateDN = $Templates_new_group_obj.distinguishedname
            $ChangeRemoveTemplateDN = $Templates_remove_group_obj.distinguishedname
            
            $NewJobCodeTemplateUsers = BGUGetTemplateUsers "$ChangeNewTemplateDN"
            $RemoveJobCodeTemplateUsers = BGUGetTemplateUsers "$ChangeRemoveTemplateDN"

            $employeeDN = $ChangeEmpIDobj.distinguishedname
            
            $ChangeADdisplayName = $ChangeEmpIDobj.displayname
            $ChangeADsamAccountName = $ChangeEmpIDobj.samaccountname
            $ChangeADemail = $ChangeEmpIDobj.mail
            $ChangeNewtemplaterole = $Templates_new_group_obj.name
            $ChangeRemovetemplaterole = $Templates_remove_group_obj.name



            # write-host ($NewJobCodeTemplateUsers -like "*$employeeDN*")
            # $employeeDN

            # $NewJobCodeTemplateUsers

            # $RemoveJobCodeTemplateUsers
            # pause


            # This checks if user's newJobCode is in newgroup and oldjobcode is not in Oldgroup in AD.
            if (($NewJobCodeTemplateUsers -like "*$employeeDN*" ) -and ($RemoveJobCodeTemplateUsers -notlike "*$employeeDN*")) {


                #Create Master ticket for this user $changestaffid
                write-host $changestaffid $ADsamAccountName $ADdisplayName
                $ChangeMasterTicket = CreateMasterServiceNowIncident $changestaffid $ADsamAccountName $ADdisplayName "Change"
                $ChangeMasterTicketNumber = $ChangeMasterTicket.number 
                write-host ChangeMasterTicketNumber: $ChangeMasterTicketNumber
                # pause


                foreach ($newmember in $Templates_new_group_obj.memberof) {

                    $mem_obj_new = BGUGetApplicationsgroup "distinguishedname" "$newmember"

                    $newMail_change = $mem_obj_new.mail
                    $newgroup_change = $mem_obj_new.name
                
                    write-host mail: $newMail_change
                    write-host group: $newgroup_change

                    # Get ServiceNow Assignment group from Group's Notes attribute.
                    $ChangeNewgroupNotes = $mem_obj_new.notes
                    write-host ChangeNewgroupNotes: $ChangeNewgroupNotes
                    $ChangeNewgroupNotes_temp = $ChangeNewgroupNotes
                    $pos = $ChangeNewgroupNotes_temp.IndexOf(":")
                    $ChangeNewServiceNowAssignmentGroup = $ChangeNewgroupNotes_temp.Substring($pos + 1)
                    write-host  "NewServiceNowAssignmentGroup : $ChangeNewServiceNowAssignmentGroup"
                    



                    ScriptLog $CAT_INFO   "Sending values for ChangeADD: $changestaffid - $newMail_change - $newgroup_change"

                    Send-Email -empIDobj $ChangeEmpIDobj -Templates_group_obj $Templates_new_group_obj -ToMail $newMail_change -staffID $changestaffid -group $newgroup_change -action "ChangeAdd"
                    #ServiceNow-Incident



                    # $ChangeNewTicketObj = CreateServiceNowIncident $newgroup $ADdisplayName $newstaffid $ADsamAccountName $ADemail $newgroup $templaterole "new"
                    $ChangeNewTicketObj = CreateServiceNowIncident -master_incident $ChangeMasterTicketNumber -assignment_group $newgroup_change -employee_name $ChangeADdisplayName -employeeID $changestaffid -employee_loginID $ChangeADsamAccountName -employee_email $ChangeADemail -application_name $newgroup_change -application_role $ChangeNewtemplaterole -ServiceNowAssignmentGroup $ChangeNewServiceNowAssignmentGroup -action "ChangeNew"


                    $ChangeNewTicketNumber = $ChangeNewTicketObj.number
                    write-host  Change New ticket number: $ChangeNewTicketNumber

                    # pause




                }

                foreach ($removemember in $Templates_remove_group_obj.memberof) {


                    $mem_obj_remove = BGUGetApplicationsgroup "distinguishedname" "$removemember"

                    $removeMail_change = $mem_obj_remove.mail
                    $Removegroup_change = $mem_obj_remove.name
                
                    write-host mail: $removeMail_change
                    write-host group: $Removegroup_change

                    # Get ServiceNow Assignment group from Group's Notes attribute.
                    $ChangeRemovegroupNotes = $mem_obj_remove.notes
                    write-host ChangeNewgroupNotes: $ChangeRemovegroupNotes
                    $ChangeRemovegroupNotes_temp = $ChangeRemovegroupNotes
                    $pos = $ChangeRemovegroupNotes_temp.IndexOf(":")
                    $ChangeRemoveServiceNowAssignmentGroup = $ChangeRemovegroupNotes_temp.Substring($pos + 1)
                    write-host  "NewServiceNowAssignmentGroup : $ChangeRemoveServiceNowAssignmentGroup"
 



                    ScriptLog $CAT_INFO   "Sending values for ChangeREMOVE: $changestaffid - $removeMail_change - $Removegroup_change"

                    Send-Email -empIDobj $ChangeEmpIDobj -Templates_group_obj $Templates_remove_group_obj -ToMail $removeMail_change -staffID $changestaffid -group $Removegroup_change -action "ChangeRemove"
                    #ServiceNow-Incident



                    # $ChangeRemoveTicketObj = CreateServiceNowIncident $newgroup $ADdisplayName $newstaffid $ADsamAccountName $ADemail $newgroup $templaterole "new"
                    $ChangeRemoveTicketObj = CreateServiceNowIncident -master_incident $ChangeMasterTicketNumber -assignment_group $Removegroup_change -employee_name $ChangeADdisplayName -employeeID $changestaffid -employee_loginID $ChangeADsamAccountName -employee_email $ChangeADemail -application_name $Removegroup_change -application_role $ChangeRemovetemplaterole -ServiceNowAssignmentGroup $ChangeRemoveServiceNowAssignmentGroup -action "ChangeRemove"


                    $ChangeRemoveTicketNumber = $ChangeRemoveTicketObj.number
                    write-host  Change Remove ticket number: $ChangeRemoveTicketNumber

                    # pause




                }

                $changecompletedtime = (get-date).tostring("dd-MM-yyyy HH:mm:ss")
                $currStatus = "Completed"
                $changecompletedtimeQuery = "    update identitystore..jobcodeemailrequests set completedtime = '$changecompletedtime', Status='$currStatus', ResultDetails=''  where staffid='$changestaffid' and status IS NULL "
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $changecompletedtimeQuery 

                ScriptLog $CAT_INFO   "Change Process completed."

            } 
        
            elseif ($NewJobCodeTemplateUsers -notlike "*$employeeDN*" ) {

                $changecompletedtime = (get-date).tostring("dd-MM-yyyy HH:mm:ss")

                $currStatus = "$changestaffid did not change to new jobcode in AD yet."
                $ChangeErrorQuery = "    update identitystore..jobcodeemailrequests set completedtime = '$changecompletedtime', ResultDetails='$currStatus' where staffid='$changestaffid' and status IS NULL "
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $ChangeErrorQuery 

                write-host "$changestaffid did not change to new jobcode in AD yet."
                ScriptLog $CAT_INFO   "$changestaffid did not change to new jobcode in AD yet."
            }
            
            elseif ($RemoveJobCodeTemplateUsers -like "*$employeeDN*" ) {

                $changecompletedtime = (get-date).tostring("dd-MM-yyyy HH:mm:ss")

                $currStatus = "$changestaffid did not got removed from old jobcode in AD yet."
                $ChangeErrorQuery = "    update identitystore..jobcodeemailrequests set completedtime = '$changecompletedtime', ResultDetails='$currStatus' where staffid='$changestaffid' and status IS NULL "
                ExecuteSqlQuery $SQLServer $SQLDBName $SQLDBUser $SQLDBPwd $ChangeErrorQuery 

                write-host "$changestaffid did not got removed from old jobcode in AD yet."
                ScriptLog $CAT_INFO   "$changestaffid did not got removed from old jobcode in AD yet."
            }
           
            
        }
    
    
    }

}

ScriptLog $CAT_INFO   "***Send-Email Program Started*** "


Process-JobCodes "NEW"
Process-JobCodes "Remove"
Process-JobCodes "Change"


#stop-transcript