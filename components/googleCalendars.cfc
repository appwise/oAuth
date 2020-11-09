<!---
	Written long hand to increase readability.....
--->

<cfcomponent extends="oAuth" output="no">

	<cffunction name="init" access="public" returnType="googleCalendars" output="false" hint="Initializes the timezone formatting required of Google">
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
    
    <cffunction name="authCalendar" access="remote" returntype="struct" hint="Authorizes the use of the Calendar API">
    	<cfargument name="access_token" type="string" required="yes" hint="oAuth access token recieved when user authenticated.  Stored as GoogleAPI.ACCESS_TOKEN under the scope of either session or client.">
        <cfargument name="Consumer_Key" type="string" required="yes" hint="Consumer Key available at accounts.google.com/UpdateDomain">
        
    	<cfset success = false>
        
        <cfif isDefined("Session.googleapi.id")>
        	<cfset user = "#Session.googleapi.id#">
        <cfelse>
        	<cfset user = "primary">
        </cfif>
        
        <cfset timestamp = application.requestFunctions.timeStampConvert()>
        <!---<cfset timestamp = timeStampConvert()>--->
        
        <cfset nonce = application.requestFunctions.nonceCreate()>
        <!---<cfset nonce = nonceCreate()>--->
        
		<cfset request_url = "https://www.googleapis.com/auth/calendar?oauth_consumer_key=#arguments.Consumer_Key#&oauth_nonce=#nonce#&oauth_timestamp=#timestamp#&oauth_token=#arguments.access_token#&oauth_version=2.0">
        
        <cfset signature = application.requestFunctions.signatureCreate(request_url)>
		<!---<cfset signature = signatureCreate(request_url)>--->
        
	        <!---https://www.googleapis.com/auth/calendar--->
    	<cfhttp method="get" url="https://www.googleapis.com/auth/calendar" result="authResult">
        	<cfhttpparam type="header" name="GData-Version" value="3.0">
            <cfhttpparam type="header" name="Content-Type" value="application/json; charset=UTF-8">
            <!---<cfhttpparam type="header" name="Authorization" value="Oauth oauth_token=#session.GoogleAPI.access_token#">--->
            <cfhttpparam type="header" name="Content-Type" value=" application/atom+xml">
            <cfhttpparam type="formfield" name="oauth_consumer_key" value="#arguments.Consumer_Key#">
            <cfhttpparam type="formfield" name="oauth_nonce" value="#nonce#">
            <cfhttpparam type="formfield" name="oauth_signature" value="#signature#">
            <cfhttpparam type="formfield" name="oauth_signature_method" value="HMAC-SHA1">
            <cfhttpparam type="formfield" name="oauth_timestamp" value="#timestamp#">
            <cfhttpparam type="formfield" name="oauth_token" value="#arguments.access_token#">
            <cfhttpparam type="formfield" name="oauth_version" value="2.0">
        </cfhttp>
			<cfif isDefined("authResult.fileContent")>
                <cfset success = true>
            </cfif>
        <cfreturn authResult>
    </cffunction>
    
    <cffunction name="retrieveCalendarList" access="remote" returntype="any" hint="Pulls the list of authenticated user's current calendars.">
    	<cfargument name="access_token" type="string" required="yes" hint="oAuth access token recieved when user authenticated.  Stored as GoogleAPI.ACCESS_TOKEN under the scope of either session or client.">
        <cfargument name="API_key" type="string" required="yes" hint="API Key available at code.google.com/apis/console">
            
          <cfhttp method="GET" url="https://www.googleapis.com/calendar/v3/users/me/calendarList?pp=1&key=#arguments.API_key#" result="listResult" >
          		<cfhttpparam type="header" name="Accept" value="*/*">
                <cfhttpparam type="header" name="Accept-Language" value="en-us">
              	<cfhttpparam type="header" name="Authorization" value="OAuth #arguments.access_token#">
              	<cfhttpparam type="header" name="Accept-Encoding" value="gzip, deflate">
              	<cfhttpparam type="header" name="Connection" value="Keep-Alive">
          </cfhttp>
          
          
			<cfif !IsJSON(listResult.fileContent)> 
                <h3>The URL you requested does not provide valid JSON</h3> 
             	<cfset success = false>
            <!--- If the data is in JSON format, deserialize it. ---> 
            <cfelse> 
                <cfset cfContact= deserializeJSON(listResult.fileContent)>
             </cfif>
			<cfif isDefined("listResult.fileContent")>
                <cfset success = true>
            </cfif>
            <!---listResult.fileContent--->
        <cfreturn cfContact> 
    </cffunction>
    
    <cffunction name="retrieveCalendarMetaData" access="remote" returntype="struct" hint="Getting the meta data, particularly GoogleAPI.calendarMeta.id allows you to interact with the cladars (read, write).">
    	<cfargument name="access_token" type="string" required="yes" hint="oAuth access token recieved when user authenticated.  Stored as GoogleAPI.ACCESS_TOKEN under the scope of either session or client.">
        <cfargument name="API_key" type="string" required="yes" hint="API Key available at code.google.com/apis/console">
            
          <cfhttp method="GET" url="https://www.googleapis.com/calendar/v3/calendars/primary?pp=1&key=#arguments.API_key#" result="listMeta" >
          		<cfhttpparam type="header" name="Accept" value="*/*">
                <cfhttpparam type="header" name="Accept-Language" value="en-us">
              	<cfhttpparam type="header" name="Authorization" value="OAuth #arguments.access_token#">
              	<cfhttpparam type="header" name="Accept-Encoding" value="gzip, deflate">
              	<cfhttpparam type="header" name="Connection" value="Keep-Alive">
          </cfhttp>
          
          
			<cfif IsJSON(listMeta.fileContent)> 
                <cfset cfContact=DeserializeJSON(listMeta.fileContent)> 
                <!---<cfscript>
					GoogleAPI["CalendarMetaData"] = StructNew();
					GoogleAPI.CalendarMetaData["id"] = "#cfContact.id#";
					GoogleAPI.CalendarMetaData["eTag"] = "#cfContact.etag#";
					GoogleAPI.CalendarMetaData["kind"] = "#cfContact.kind#";
					GoogleAPI.CalendarMetaData["summary"] = "#cfContact.summary#";
					GoogleAPI.CalendarMetaData["timeZone"] = "#cfContact.timeZone#";
				</cfscript> --->
                 <!---Its best to lock session vars to prevent conflicts from deadlocks--->
                   <cflock scope="session" timeout="5">
                   		<cfset session.GoogleAPI.calendarMeta.id=cfContact.id>
                        <cfset session.GoogleAPI.calendarMeta.etag=cfContact.etag>
                        <cfset session.GoogleAPI.calendarMeta.kind=cfContact.kind>
                        <cfset session.GoogleAPI.calendarMeta.summary=cfContact.summary>
                        <cfset session.GoogleAPI.calendarMeta.timeZone=cfContact.timeZone>
                   </cflock>
            <cfelseif  IsXML(listMeta.fileContent)>
            	<h3>The URL you requested provided valid JSON</h3> 
             	<cfset success = false>
            </cfif>
            
        <cfreturn session.GoogleAPI.calendarMeta> 
    </cffunction>
    
    <cffunction  name="listAllCalendarEvents" access="remote" returntype="any" hint="Lists all events for a particular calendar (GoogleAPI.calendarMeta.id).">
        <cfargument name="access_token" type="string" required="yes" hint="oAuth access token recieved when user authenticated.  Stored as GoogleAPI.ACCESS_TOKEN under the scope of either session or client.">
        <cfargument name="API_key" type="string" required="yes" hint="API Key available at code.google.com/apis/console">
        <cfargument name="calendarMeta_id" type="string" required="yes" hint="as is returned in method googleCalendars.retrieveCalendarMetaData()">
        
    	<cfhttp method="Get" url="https://www.googleapis.com/calendar/v3/calendars/#arguments.calendarMeta_id#/events?pp=1&key=#arguments.API_key#" result="eventsResult" >
        		<cfhttpparam type="header" name="Accept" value="*/*">
                <cfhttpparam type="header" name="Accept-Language" value="en-us">
              	<cfhttpparam type="header" name="Authorization" value="OAuth #arguments.access_token#">
              	<cfhttpparam type="header" name="Accept-Encoding" value="gzip, deflate">
              	<cfhttpparam type="header" name="Connection" value="Keep-Alive">
        </cfhttp>
        
        <cfreturn eventsResult.fileContent>
    </cffunction>
    
     <cffunction name="reminderCalendarEventInsert" access="remote" returntype="any" hint="Inserts a simple reminder based on summary (event title), description">
    	<cfargument name="summary" type="string" required="yes">
        <cfargument name="description" type="string" required="yes">
        <cfargument name="startDate" type="string" required="yes">
        <cfargument name="endDate" type="string" required="yes"> 
        <cfargument name="access_token" type="string" required="yes" hint="oAuth access token recieved when user authenticated.  Stored as GoogleAPI.ACCESS_TOKEN under the scope of either session or client.">
        <cfargument name="API_key" type="string" required="yes" hint="API Key available at code.google.com/apis/console">
        <cfargument name="calendarMeta_id" type="string" required="yes" hint="as is returned in method googleCalendars.retrieveCalendarMetaData()">
        
        <cfscript>
			thestruct = StructNew();
			thestruct["summary"] = "#arguments.summary#";
			thestruct["description"] = "#arguments.description#";
			thestruct["start"] = structnew();
			thestruct.start["dateTime"] = "#arguments.startDate#";
			thestruct["end"] = structnew();
			thestruct.end["dateTime"] = "#arguments.endDate#";
			thestruct["reminders"] = structnew();
			thestruct.reminders["useDefault"] = true;
		</cfscript>
		<cfinvoke component="components.JSON" method="encode" data="#thestruct#" returnvariable="postJson" />

        
          <cfhttp method="POST" url="https://www.googleapis.com/calendar/v3/calendars/#arguments.calendarMeta_id#/events?pp=1&key=#arguments.API_key#"  result="listEventData" >
          		<cfhttpparam type="header" name="Accept" value="*/*">
                <cfhttpparam type="header" name="Accept-Language" value="en-us">
              	<cfhttpparam type="header" name="Authorization" value="OAuth #arguments.access_token#">
                <cfhttpparam type="header" name="Content-Type" value="application/json">
              	<cfhttpparam type="header" name="Accept-Encoding" value="gzip, deflate">
                <cfhttpparam type="header" name="Connection" value="Keep-Alive">
                <cfhttpparam type="body" value="#postJson#">    
          </cfhttp>
          
			
			<cfif isDefined("listEventData.fileContent")>
                <cfset success = true>
            </cfif>
            <cfdump var="#listEventData#">
        <cfreturn listEventData.fileContent> 
    </cffunction>
    
    <cffunction name="importEvents" access="remote" returntype="struct" hint="Pulls down all the events in a authentiacted user's calendar.">
    	<cfargument name="access_token" type="string" required="yes" hint="oAuth access token recieved when user authenticated.  Stored as {scope}.GoogleAPI.ACCESS_TOKEN">
        <cfargument name="API_key" type="string" required="yes" hint="should be an application scoped variable: GET IT HERE: code.google.com/apis/console">
        <cfargument name="Consumer_Key" type="string" required="yes" hint="should be an application scoped variable: GET IT HERE: https://accounts.google.com/UpdateDomain">
        <cfargument name="consumer_secret" type="string" required="yes" hint="should be an application scoped variable: GET IT HERE: https://accounts.google.com/UpdateDomain">
        <cfargument name="client_secret" type="string" required="yes" hint="should be an application scoped variable: GET IT HERE: code.google.com/apis/console">
        <cfargument name="googleapi_id" type="string" required="no" hint="comes from {scope}.GoogleAPI.VALIDATEDUSERINFO.ID">
        
    	<cfset success = false>
        <cfif isDefined("arguments.googleapi_id")>
        	<cfset user = "#arguments.googleapi_id#">
        <cfelse>
        	<cfset user = "primary">
        </cfif>
        <cfscript>
        var nowUTC = dateConvert('local2UTC', now()); 
        var epochStart = CreateDateTime('1970','1','1','00','00','00'); 
        var timestamp = dateDiff("s", epochStart, nowUTC); 
		 var uuid = createUUID(); 
        //Convert the UUID to a GUID by inserting a dash in the 23rd position 
        var nonce = insert("-", uuid, 23);
		</cfscript>
        
        <!---https://www.googleapis.com/auth/calendar--->
		<cfset request_url = "https://apps-apis.google.com/a/feeds/calendar/resource/2.0?oauth_consumer_key=#arguments.Consumer_Key#&oauth_nonce=#nonce#&oauth_timestamp=#timestamp#&oauth_token=#arguments.access_token#&oauth_version=2.0">
        
		<cfset request_url_address = request_url>	
        	
		<cfset request_url_query_string = "">
        				
		<cfset question_mark = Find("?",request_url,1)>	
        			
		<cfif question_mark neq 0>					
			<cfset request_url_address = Left(request_url,question_mark-1)>			
            <cfset request_url_query_string = Right(request_url,(len(request_url)-question_mark))>					
            <!--- ************************************************************ --->			
            <!--- Repeat for each key/value pair                               --->			
            <!--- ************************************************************ --->			
            <cfset request_url_query_string = Replace(request_url_query_string, "&&", "PLACEHOLDER_AMPERSAND", "ALL")>	
            <!--- save escaped ampersand (&) symbols --->			
            <cfset request_url_query_string = Replace(request_url_query_string, "==", "PLACEHOLDER_EQUALS", "ALL")>  
            <!--- save escaped equals (=) symbols --->			
            <cfset params_list = ListChangeDelims(request_url_query_string,",","&,=")>						
                <cfloop from="1" to="#ListLen(params_list)#" index="index" step="2">		
                			
                    <!--- Add parameter to Params structure --->				
			
                    <cfset params[ListGetAt(params_list,index)] = ListGetAt(params_list,index+1)>					
                    <cfset params[ListGetAt(params_list,index)] = Replace(params[ListGetAt(params_list,index)], "PLACEHOLDER_AMPERSAND", "&", "ALL")>	
                    <!--- restore escaped ampersand (&) symbols as non-escaped --->				
                    <cfset params[ListGetAt(params_list,index)] = Replace(params[ListGetAt(params_list,index)], "PLACEHOLDER_EQUALS", "=", "ALL")>	
                    <!--- restore escaped equals (=) symbols as non-escaped --->			
                </cfloop>					
        </cfif>
            <!--- BEGIN: Generate signature base string --->	
            	
            <!--- All parameters must be URL-encoded to RFC 3986 scheme --->
            <!--- http://cookbooks.adobe.com/post_URL_encoding_to_RFC_3986-17970.html --->				
        
            <cfloop list="#StructKeyList(params)#" index="key">					
                <cfset params[key] = URLEncodedFormatRFC3986(params[key])>			
            </cfloop>	
            	
            <!--- Get the base string --->	
                    
            <cfset signature_base_string = oAuthBaseStringify(http_method,request_url_address,params)>		
             
            <!--- Generate composite signing key --->		
            
            <cfset composite_signing_key = #arguments.consumer_secret# & "&" & #arguments.client_secret#>		
            	
            <!--- BEGIN: SHA1 hash routine --->		
            
            <cfset signature = ToBase64(HMAC_SHA1(composite_signing_key,signature_base_string))>
            	
            <!--- URL encode the HASH --->			
            
            <cfset signature = URLEncodedFormatRFC3986(signature)>	
                 <cfhttp method="get" url="https://apps-apis.google.com/a/feeds/calendar/resource/2.0?key=#arguments.API_key#" result="calendarList">
                    <cfhttpparam type="header" name="GData-Version" value="2">
                        <cfhttpparam type="formfield" name="oauth_consumer_key" value="#arguments.Consumer_Key#">
                        <cfhttpparam type="formfield" name="oauth_nonce" value="#nonce#">
                        <cfhttpparam type="formfield" name="oauth_signature" value="#signature#">
                        <cfhttpparam type="formfield" name="oauth_signature_method" value="HMAC-SHA1">
                        <cfhttpparam type="formfield" name="oauth_timestamp" value="#timestamp#">
                        <cfhttpparam type="formfield" name="oauth_token" value="#arguments.access_token#">
                        <cfhttpparam type="formfield" name="oauth_version" value="2.0">
                    </cfhttp>
    
            <cfif isDefined("calendarList.fileContent")>
                <cfset success = true>
                
            </cfif>
        <cfreturn calendarList>
    </cffunction>

    <cffunction name="hmac_sha1" returntype="string" access="package" hint="HMAC SHA1 encoding of the string using JAVA.  All blogs are telling me that encoding SHA1 with cfencode does not produce an acceptable string for oAuth.  We did proove that that is correct.">  
        <cfargument name="signKey" type="string" required="true">  
        <cfargument name="signMessage" type="string" required="true">  
        <cfargument name="sFormat" type="string" required="false" default="iso-8859-1">    
        
			<cfset var jMsg = JavaCast("string", arguments.signMessage).getBytes(arguments.sFormat)>  
            <cfset var jKey = JavaCast("string", arguments.signKey).getBytes(arguments.sFormat)>    
            <cfset var key = createObject("java", "javax.crypto.spec.SecretKeySpec")>  
            <cfset var mac = createObject("java", "javax.crypto.Mac")>    
            <cfset key = key.init(jKey,"HmacSHA1")>    
            <cfset mac = mac.getInstance(key.getAlgorithm())>  
            <cfset mac.init(key)>  <cfset mac.update(jMsg)>    
    	<cfreturn ToBase64(mac.doFinal())>  
    </cffunction>
 
    
    <cffunction name="URLEncodedFormatRFC3986" returntype="string" access="package" description="http://cookbooks.adobe.com/post_URL_encoding_to_RFC_3986-17970.html" hint="http://cookbooks.adobe.com/post_URL_encoding_to_RFC_3986-17970.html" output="no">	
    	<cfargument name="url" type="string" required="true" />	
	
			<cfset rfc_3986_bad_chars = "%2D,%2E,%5F,%7E">	
			<cfset rfc_3986_good_chars = "-,.,_,~">	
			<cfset url = ReplaceList(URLEncodedFormat(url),rfc_3986_bad_chars,rfc_3986_good_chars)>	   
    	<cfreturn url />
    </cffunction>
    
    <cffunction name="oAuthBaseStringify" returntype="string" access="package" output="no" hint="Creates the oAuth Base String for the Signature">	
    
        <!--- Required parameters (http_method, base_uri, values)  --->	
        
        <cfargument name="http_method" type="string" required="true">	
        <cfargument name="base_uri" type="string" required="true">	
        <cfargument name="parameters" type="struct" required="true">	
        
        <!--- Concatenate http_method & URL-encoded base_uri --->	
        
            <cfset oauth_signature_base_string = http_method & "&" & URLEncodedFormatRFC3986(base_uri) & "&">	
            
        <!--- Create sorted list of parameter keys --->	
            <cfset keys_list = StructKeyList(parameters)>	
            <cfset keys_list_sorted = ListSort(keys_list,"textnocase")>		
            <cfset amp = "">	
        <!--- first iteration requires no ampersand --->	
        	
        <!--- Repeat for each parameter                                    --->	
        	
            <cfloop list="#keys_list_sorted#" index="key">			
            		
                <!--- Concatenate URL-encoded parameter (key/value pair) --->	
                	
                <cfset oauth_signature_base_string = oauth_signature_base_string & URLEncodedFormatRFC3986(amp & LCase(key) & "=" & parameters[key])>		
                <cfset amp = "&">	
                <!--- successive iterations require a starting ampersand --->			
            </cfloop>		
            
        <!--- Return with OAuth signature base string  --->	
        
    	<cfreturn oauth_signature_base_string>	
    </cffunction> 
</cfcomponent>
