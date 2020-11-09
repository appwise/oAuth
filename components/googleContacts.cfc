<!---
	Written long hand to increase readability.....
--->

<cfcomponent extends="oAuth" output="no">
	
    <cffunction name="init" access="public" returnType="googleContacts" output="false">
		<cfargument name="tzoffset" type="string" required="false" default="" hint="Timezone offset. Will default to system offset.">
		<cfset var tz = "">
			
		<cfif structKeyExists(arguments, "tzOffset") and isNumeric(arguments.tzOffset)>
			<cfset variables.tzOffset = arguments.tzOffset>
		<cfelse>
			<cfset tz = getTimeZoneInfo()>
			<cfset variables.tzOffset = tz.utcHourOffset>
		</cfif>


		<cfreturn this>
	</cffunction>
    
    <cffunction name="getValidatedUserInfo" access="remote" returntype="struct" hint="This returns all the information about the validated user which will allow you to interact with various Google APIs including Calendars API. You must specify a storage solution which meets the Google Terms of Service (TOS) for the API.">
    	<cfargument name="access_token" type="string" required="yes" hint="oAuth access token recieved when user authenticated.  Stored as GoogleAPI.ACCESS_TOKEN under the scope of either session or client.">
        <cfargument name="Consumer_Key" type="string" required="yes" hint="Should be a application scoped variable.  GET IT HERE: https://accounts.google.com/UpdateDomain">
        
    	<cfset success = false>
        
    	<cfhttp method="get" url="https://www.googleapis.com/oauth2/v1/userinfo?access_token=#arguments.access_token#" result="userResult" />
        
        <cfif isDefined("userResult.fileContent")>

         <cfset theContact=REReplace(userResult.fileContent,  
                    "^\s*[[:word:]]*\s*\(\s*","")> 
            <cfset theContact=REReplace(theContact, "\s*\)\s*$", "")> 
             
            <!--- Test to make sure you have JSON data. ---> 
            <cfif !IsJSON(theContact)> 
                <h3>The URL you requested does not provide valid JSON</h3> 
             	<cfset success = false>
            <!--- If the data is in JSON format, deserialize it. ---> 
            <cfelse> 
                <cfset cfContact=DeserializeJSON(theContact)>
                	<!--- Its best to lock session vars to prevent conflicts from deadlocks --->
                   <cflock scope="session" timeout="5">
						<cfset session.GoogleAPI.validatedUserInfo["id"]=cfContact.id> 
                        <cfset session.GoogleAPI.validatedUserInfo["email"]=cfContact.email> 
                        <cfset session.GoogleAPI.validatedUserInfo["verified_email"]=cfContact.verified_email> 
                        <cfset session.GoogleAPI.validatedUserInfo["name"]=cfContact.name>
                        <cfset session.GoogleAPI.validatedUserInfo["given_name"]=cfContact.given_name>
                        <cfset session.GoogleAPI.validatedUserInfo["family_name"]=cfContact.family_name>
                        <cfif isDefined("cfContact.picture")>
                        <cfset session.GoogleAPI.validatedUserInfo["picture"]=cfContact.picture>
                        <cfelse>
                        <cfset session.GoogleAPI.validatedUserInfo["picture"]=''>
                        </cfif>
                        <cfif isDefined("cfContact.locale")>
                        <cfset session.GoogleAPI.validatedUserInfo["locale"]=cfContact.locale>
                        <cfelse>
                        <cfset session.GoogleAPI.validatedUserInfo["locale"]=''>
                        </cfif>
                        <cfif isDefined("cfContact.timezone")>
                        <cfset session.GoogleAPI.validatedUserInfo["timezone"]=cfContact.timezone>
                        <cfelse>
                        <cfset session.GoogleAPI.validatedUserInfo["timezone"]=''>
                        </cfif>
                        <cfif isDefined("cfContact.gender")>
                        <cfset session.GoogleAPI.validatedUserInfo["gender"]=cfContact.gender>
                        <cfelse>
                        <cfset session.GoogleAPI.validatedUserInfo["gender"]=''>
                        </cfif>
                   </cflock>
  
                <cfstoredproc procedure="dbo.sproc_ipTrackerEmailUpdate" datasource="appwise">
                	<cfprocparam cfsqltype="cf_sql_varchar" value="#cfContact.email#">
                    <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.Remote_Addr#">
                </cfstoredproc>

              <cfset success = true>
          </cfif>
       </cfif>
       <cfreturn session.GoogleAPI.validatedUserInfo>
    </cffunction>
    
    <cffunction name="getMyContacts" access="remote" returntype="any" hint="Draws down the entire available contact list (see Documentation/atom_Contact_Schema.txt). You must specify a storage solution which meets the Google Terms of Service (TOS) for the API.">
		<cfargument name="access_token" type="string" required="yes" hint="oAuth access token recieved when user authenticated.  Stored as GoogleAPI.ACCESS_TOKEN under the scope of either session or client.">
        
		<cfset var result = "">
		<cfset var conListXML = "">
		<cfset var numCons = 0>
		<cfset var x = "">
		<cfset var entry = "">
		<cfset var con = "">
		<cfset var y = "">
		<cfset var s = "">
		<cfset var sentry = "">
		<cfset var label = "">
		<cfset var a = "">
		<cfset var cons = arrayNew(1)>
		<cfset var finalResult = structNew()>
		
		
		<!---<cfset refreshToken = application.oAuth.refreshToken()>	--->
		 <cfhttp url="https://www.google.com/m8/feeds/contacts/default/full?oauth_token=#arguments.access_token#&max-results=100" method="get" result="result" />	
         
		<cfif not result.responseheader.status_code is "200">
			<cfreturn result>
		</cfif>
		
		<cfset conListXML = xmlParse(result.filecontent)>
		
		<cfif structKeyExists(conListXML.feed, "entry")>
			<cfset numCons = arrayLen(conListXML.feed.entry)>
		</cfif>
		
		<cfif structKeyExists(conListXML.feed, "openSearch:totalResults")>
			<cfset finalResult.totalContacts = conListXML.feed["openSearch:totalResults"].xmlText>
		<cfelse>
			<cfset finalResult.totalContacts = 0>
		</cfif>
		
		<cfloop index="x" from="1" to="#numCons#">
			<cfset entry = conListXML.feed.entry[x]>

			<cfset con = structNew()>
			<cfset con.id = listLast(entry.id.xmlText,"/")>
			<cfset con.updated = convertDate(entry.updated.xmltext, variables.tzoffset)>
			<cfset con.title = entry.title.xmlText>

			<!--- support multiple email addresses --->
			<cfset a = arrayNew(1)>
			<!--- this is a convenience key, i do this just for emails --->
			<cfset con.primaryemail = "">
			<cfif structKeyExists(entry, "gd:email")>					
					<cfloop index="y" from="1" to="#arrayLen(entry["gd:email"])#">
						<cfset sentry = entry["gd:email"][y]>
						<cfset s = structNew()>
						<!--- if no label, use the end of rel --->
						<cfif not structKeyExists(sentry.xmlAttributes,"label")>
							<cfset label = listLast(sentry.xmlAttributes.rel,"##")>
						<cfelse>
							<cfset label = sentry.xmlAttributes.label>
						</cfif>
						<cfset s.label = label>
													
						<cfset s.address = sentry.xmlAttributes.address>

						<cfif structKeyExists(sentry.xmlAttributes,"primary")>
							<cfset s.primary = sentry.xmlAttributes.primary>
							<cfset con.primaryemail = s.address>
						<cfelse>
							<cfset s.primary = false>
						</cfif>	
						<cfset arrayAppend(a, s)>						
					</cfloop>
				</cfif>
				<cfset con.email = a>

				<!--- support multiple IM networks --->
				<cfset a = arrayNew(1)>
				<cfif structKeyExists(entry, "gd:im")>
					<cfloop index="y" from="1" to="#arrayLen(entry["gd:im"])#">
						<cfset sentry = entry["gd:im"][y]>
						<cfset s = structNew()>
						<!--- if no label, use the end of rel --->
						<cfif not structKeyExists(sentry.xmlAttributes,"label")>
							<cfset label = listLast(sentry.xmlAttributes.rel,"##")>
						<cfelse>
							<cfset label = sentry.xmlAttributes.label>
						</cfif>
						<cfset s.label = label>
													
						<!--- protocal is the network, just get after # --->
						<cfset s.network  = listLast(sentry.xmlAttributes.protocol,"##")>
						<cfset s.address = sentry.xmlAttributes.address>
						<cfif structKeyExists(sentry.xmlAttributes,"primary")>
							<cfset s.primary = sentry.xmlAttributes.primary>
						<cfelse>
							<cfset s.primary = false>
						</cfif>	
						<cfset arrayAppend(a, s)>						
					</cfloop>
				</cfif>
				<cfset con.im = a>
				
				<!--- support multiple organizations --->
				<cfset a = arrayNew(1)>
				<cfif structKeyExists(entry, "gd:organization")>
					<cfloop index="y" from="1" to="#arrayLen(entry["gd:organization"])#">
						<cfset sentry = entry["gd:organization"][y]>
						<cfset s = structNew()>
	
						<!--- if no label, use the end of rel --->
						<cfif not structKeyExists(sentry.xmlAttributes,"label")>
							<cfset label = listLast(sentry.xmlAttributes.rel,"##")>
						<cfelse>
							<cfset label = sentry.xmlAttributes.label>
						</cfif>
						<cfset s.label = label>
						<cfif structKeyExists(sentry.xmlAttributes,"primary")>
							<cfset s.primary = sentry.xmlAttributes.primary>
						<cfelse>
							<cfset s.primary = false>
						</cfif>
						<cfif structKeyExists(sentry, "gd:orgName")>
							<cfset s.name = sentry["gd:orgName"].xmlText>
						</cfif>
						<cfif structKeyExists(sentry, "gd:orgTitle")>
							<cfset s.title = sentry["gd:orgTitle"].xmlText>
						</cfif>
						<cfset arrayAppend(a,s)>
					</cfloop>
				</cfif>
				<cfset con.organization = a>

				<!--- support multiple phones --->
				<cfset a = arrayNew(1)>
				<cfif structKeyExists(entry, "gd:phoneNumber")>
					<cfloop index="y" from="1" to="#arrayLen(entry["gd:phoneNumber"])#">
						<cfset sentry = entry["gd:phoneNumber"][y]>
						<cfset s = structNew()>
	
						<!--- if no label, use the end of rel --->
						<cfif not structKeyExists(sentry.xmlAttributes,"label")>
							<cfset label = listLast(sentry.xmlAttributes.rel,"##")>
						<cfelse>
							<cfset label = sentry.xmlAttributes.label>
						</cfif>
						<cfset s.label = label>
						<cfif structKeyExists(sentry.xmlAttributes,"primary")>
							<cfset s.primary = sentry.xmlAttributes.primary>
						<cfelse>
							<cfset s.primary = false>
						</cfif>
						<cfif structKeyExists(sentry.xmlAttributes,"uri")>
							<cfset s.uri = sentry.xmlAttributes.uri>
						<cfelse>
							<cfset s.uri = "">
						</cfif>
						<cfset s.number = sentry.xmlText>
						<cfset arrayAppend(a,s)>
					</cfloop>
				</cfif>
				<cfset con.phonenumber = a>

				<!--- support multiple addresses --->
				<cfset a = arrayNew(1)>
				<cfif structKeyExists(entry, "gd:postalAddress")>
					<cfloop index="y" from="1" to="#arrayLen(entry["gd:postalAddress"])#">
						<cfset sentry = entry["gd:postalAddress"][y]>
						<cfset s = structNew()>
	
						<!--- if no label, use the end of rel --->
						<cfif not structKeyExists(sentry.xmlAttributes,"label")>
							<cfset label = listLast(sentry.xmlAttributes.rel,"##")>
						<cfelse>
							<cfset label = sentry.xmlAttributes.label>
						</cfif>
						<cfset s.label = label>
						<cfif structKeyExists(sentry.xmlAttributes,"primary")>
							<cfset s.primary = sentry.xmlAttributes.primary>
						<cfelse>
							<cfset s.primary = false>
						</cfif>
						<cfset s.number = sentry.xmlText>
						<cfset arrayAppend(a,s)>
					</cfloop>
				</cfif>
				<cfset con.postalAddress = a>						

				<!--- support multiple groups --->
				<cfset a = arrayNew(1)>
				<cfif structKeyExists(entry, "gContact:groupMembershipInfo")>
					<cfloop index="y" from="1" to="#arrayLen(entry["gContact:groupMembershipInfo"])#">
						<cfset sentry = entry["gContact:groupMembershipInfo"][y]>
						<cfset s = structNew()>
						<cfset s.id = sentry.xmlAttributes.href>
						<cfset s.deleted = sentry.xmlAttributes.deleted>
						<cfset arrayAppend(a,s)>
					</cfloop>
				</cfif>
				<cfset con.groups = a>						
				
				<cfif structKeyExists(entry, "content")>
					<cfset con.content = entry.content.xmlText>
				<cfelse>
					<cfset con.content = "">
				</cfif>
				<cfset arrayAppend(cons, con)>
			</cfloop>
			<cfset finalResult.contacts = cons>
				<!--- Final Results Array Structure :: So you know how to store it --->
                <!---
					This is an array
					CONTENT  {type: string}
					EMAIL  {type:array}
						ADDRESS  {type: string}  
						LABEL  {type: string}  
						PRIMARY  {type: boolean}  
					 
					 
					GROUPS  {type:array} 
					 
					ID  {type:numeric} 
					IM  {type:array} 
					 
					ORGANIZATION  {type:array} 
					 
					PHONENUMBER  {type:array} 
					 
					POSTALADDRESS  {type:array} 
					 
					PRIMARYEMAIL  {type: string} 
					TITLE  {type: string}  
					UPDATED  {type: timestamp}  
                --->
		<cfreturn finalResult.contacts>
    </cffunction>
    
    <cffunction name="getLatest"  access="remote" hint="Gets the latest contact information from a date specified.  If there is no new information from that date the struct will be empty.">
        <cfargument name="latestDate" default="12/1/2001" type="date" required="yes" hint="The latest date from the initial contact draw down using getMyContacts(access_token).  You must specify a storage solution which meets the Google TOS for the API.">
        <cfargument name="access_token" type="string" required="yes" hint="oAuth access token recieved when user authenticated.  Stored as GoogleAPI.ACCESS_TOKEN under the scope of either session or client.">
        <cfargument name="GoogleAPI_email" type="string" required="yes" hint="This is the email of the authenticated user">
    
		<cfhttp method="get" url="https://www.google.com/m8/feeds/contacts/#arguments.GoogleAPI_email#/full?updated-min=#dateFormat(arguments.latestDate,'yyyy-mm-dd')#T00:00:00" result="latestContacts">
        	<cfhttpparam type="header" name="GData-Version" value="3.0">
            <cfhttpparam type="header" name="Authorization" value="GoogleLogin auth=#arguments.access_token#">
        	
        </cfhttp>
		<cfreturn latestContacts>
	</cffunction>
    
    <cffunction name="insertContact" access="remote" hint="Adds a contact to the authenticated user's contact list.">
    
		<cfargument name="FirstName" type="string" required="true" hint="Joe">
		<cfargument name="LastName" type="string" required="true" hint="Smith">
        <cfargument name="organization_Name" type="string" required="false" hint="XYZ Corp">
        <cfargument name="organization_Title" type="string" required="false" hint="Assistant Yes Man">
        <cfargument name="work_city" type="string" required="false" hint="Baltimore">
		<cfargument name="work_address1" type="string" required="false" hint="57310 Commerce Street">
		<cfargument name="work_state" type="string" required="false" hint="MD">
        <cfargument name="work_postal_code" type="string" required="false" hint="12345">
		<cfargument name="work_country" type="string" required="false" hint="United States">
        <cfargument name="work_email" type="string" required="false" hint="foo@bigboxcorp.com">
        <cfargument name="home_city" type="string" required="false" hint="Baltimore">
		<cfargument name="home_address1" type="string" required="false" hint="123 Main Street">
		<cfargument name="home_state" type="string" required="false" hint="MD">
        <cfargument name="home_postal_code" type="string" required="false" hint="12345">
		<cfargument name="home_country" type="string" required="false" hint="United States">
		<cfargument name="home_email" type="string" required="false" hint="foo@bar.com">
        <cfargument name="workPhone" type="string" required="false" hint="999-999-9999">
        <cfargument name="homePhone" type="string" required="false" hint="999-999-9999">
        <cfargument name="mobilePhone" type="string" required="false" hint="999-999-9999">
        <cfargument name="faxPhone" type="string" required="false" hint="999-999-9999">
        <cfargument name="otherPhone" type="string" required="false" hint="999-999-9999">
        <cfargument name="GoogleAPI_email" type="string" required="yes" hint="this is the email of the authenticated user">
        <cfargument name="access_token" type="string" required="yes" hint="this is the BEARER access_token returned at authentication">
        
        <cfset fullname = '#arguments.FirstName#' & ' ' & '#arguments.LastName#'>
		<cfoutput>
        <cfsavecontent variable="gdContactXML">
            <atom:entry xmlns:atom='http://www.w3.org/2005/Atom' xmlns:gd='http://schemas.google.com/g/2005'>
				<atom:category scheme='http://schemas.google.com/g/2005##kind' term='http://schemas.google.com/contact/2008##contact'/>
 				
				<atom:content type='text'>Created by Google oAuth 2.0 Connector for ColdFusion from AppWise.org at #dateFormat(now(), "mm/dd/yyyy")# #timeFormat(now(), "hh:mm:ss tt")# EST</atom:content>
              <gd:name>
                <gd:givenName>#arguments.FirstName#</gd:givenName>
                <gd:familyName>#arguments.LastName#</gd:familyName>
                <gd:fullName>#xmlFormat(fullname, true)#</gd:fullName>
              </gd:name>
              
             
              <gd:structuredPostalAddress rel='http://schemas.google.com/g/2005##home' primary='true'>
              <cfif len(trim(arguments.home_city)) GT 0 >
                <gd:city>#xmlFormat(arguments.home_city)#</gd:city>
              </cfif>
              <cfif len(trim(arguments.home_address1)) GT 0 >
                <gd:street>#xmlFormat(arguments.home_address1)#</gd:street>
              </cfif>
              <cfif len(trim(arguments.home_state)) GT 0 >
                <gd:region>#xmlFormat(arguments.home_state)#</gd:region>
              </cfif>
              <cfif len(trim(arguments.home_postal_code)) GT 0 >
                <gd:postcode>#xmlFormat(arguments.home_postal_code)#</gd:postcode>
              </cfif>
              <cfif len(trim(arguments.home_country)) GT 0 >
                <gd:country>#xmlFormat(arguments.home_country)#</gd:country>
              </cfif>
              </gd:structuredPostalAddress>
             
              <cfif len(trim(arguments.home_email)) GT 0 >
              	<gd:email rel='http://schemas.google.com/g/2005##home' address='#xmlFormat(arguments.home_email)#' primary='false'/>
              </cfif>
             
             
              <gd:structuredPostalAddress rel='http://schemas.google.com/g/2005##work' primary='false'>
              <cfif len(trim(arguments.work_city)) GT 0 >
                <gd:city>#xmlFormat(arguments.work_city)#</gd:city>
              </cfif>
              <cfif len(trim(arguments.work_address1)) GT 0 >
                <gd:street>#xmlFormat(arguments.work_address1)# </gd:street>
               </cfif>
               <cfif len(trim(arguments.work_state)) GT 0 >
                <gd:region>#xmlFormat(arguments.work_state)#</gd:region>
               </cfif>
               <cfif len(trim(arguments.work_postal_code)) GT 0 >
                <gd:postcode>#xmlFormat(arguments.work_postal_code)#</gd:postcode>
               </cfif>
               <cfif len(trim(arguments.work_country)) GT 0 >
                <gd:country>#xmlFormat(arguments.work_country)#</gd:country>
               </cfif>
              </gd:structuredPostalAddress>
              
              <cfif len(trim(arguments.organization_Name)) GT 0>
              <gd:organization rel="http://schemas.google.com/g/2005##work" primary="true" >
					<cfif len(trim(arguments.organization_Name)) GT 0>
                    	<gd:orgName>#xmlFormat(arguments.organization_Name)#</gd:orgName>
                    </cfif>
					<cfif len(trim(arguments.organization_Title)) GT 0>
						<gd:orgTitle>#xmlFormat(arguments.organization_Title)#</gd:orgTitle>
					</cfif>
			  </gd:organization>
              </cfif>
              
               <cfif len(trim(arguments.work_email)) GT 0 >
              	<gd:email rel='http://schemas.google.com/g/2005##work' address='#xmlFormat(arguments.work_email)#' primary='false'/>
               </cfif>
               
               <cfif len(trim(arguments.workPhone)) GT 0 >
					<gd:phoneNumber rel='http://schemas.google.com/g/2005##work'>#xmlFormat(arguments.workPhone, true)#</gd:phoneNumber>
				</cfif>
				<cfif len(trim(arguments.homePhone)) GT 0 >
					<gd:phoneNumber rel='http://schemas.google.com/g/2005##home' >#xmlFormat(arguments.homePhone, true)#</gd:phoneNumber>
				</cfif>
				<cfif len(trim(arguments.mobilePhone)) GT 0 >
					<gd:phoneNumber rel='http://schemas.google.com/g/2005##mobile' >#xmlFormat(arguments.mobilePhone, true)#</gd:phoneNumber>
				</cfif>
				<cfif len(trim(arguments.faxPhone)) GT 0 >
					<gd:phoneNumber rel='http://schemas.google.com/g/2005##fax' >#xmlFormat(arguments.faxPhone, true)#</gd:phoneNumber>
				</cfif>
				<cfif len(trim(arguments.otherPhone)) GT 0 >
					<gd:phoneNumber rel='http://schemas.google.com/g/2005##other' >#xmlFormat(arguments.otherPhone, true)#</gd:phoneNumber>
				</cfif>
            </atom:entry>        
        </cfsavecontent>
		</cfoutput>
        
        
        <cfhttp method="post" url="https://www.google.com/m8/feeds/contacts/#arguments.GoogleAPI_email#/full?oauth_token=#arguments.access_token#" result="insertContact">
        	<cfhttpparam type="header" name="GData-Version" value="3.0">
            <cfhttpparam type="header" name="Accept" value="*/*">
                <cfhttpparam type="header" name="Accept-Language" value="en-us">
              	<cfhttpparam type="header" name="Authorization" value="OAuth #arguments.access_token#">
				<cfhttpparam type="header" name="Content-Type" value="application/atom+xml; charset=UTF-8; type=entry">
              	<cfhttpparam type="header" name="Accept-Encoding" value="gzip, deflate">
                <cfhttpparam type="header" name="Connection" value="Keep-Alive">
        	<cfhttpparam type="xml" value="#gdContactXML#">
        </cfhttp>
		
        
		<cfreturn insertContact>
	</cffunction>
    
    <cffunction name="convertDate" access="package" returnType="date" output="false" hint="Converts your date and time to a Google datetime object.  You know, the one with the T and ZULU in it">
		<cfargument name="date" type="string" required="true" hint="The date.">
		<cfargument name="offset" type="numeric" required="true" hint="The offset.">
		<!--- 
			You may ask, why not use getTZOffset? Some of the dates
			from google are gmt, and some are offset already, so I let the caller
			figure it out and use either the real offset, or the Diffed offset.
			
			This may be sucky. Be warned.
		--->
		<cfset arguments.date = replace(arguments.date, "T", " ")>
		<cfset arguments.date = replace(arguments.date, "Z", "")>
		<cfset arguments.date = reReplace(arguments.date, "[\-\+][0-9][0-9]:[0-9][0-9]", "")>
		<cfset arguments.date = parseDateTime(arguments.date)>
		<cfset arguments.date = dateAdd("h", arguments.offset, arguments.date)>
		<cfreturn arguments.date>
		
	</cffunction>
    
     
</cfcomponent>
