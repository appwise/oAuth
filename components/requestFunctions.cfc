<cfcomponent extends="googleCalendars" hint="Used for creating noonce, signature, timestamp">

	<cffunction name="init" access="public" output="false" hint="handles the root webservice functions">
		<cfreturn this />
    </cffunction>

	<cffunction name="timeStampConvert" access="public" returntype="numeric">
		<cfscript>
                var nowUTC = dateConvert('local2UTC', now()); 
                var epochStart = CreateDateTime('1970','1','1','00','00','00'); 
                var timestamp = dateDiff("s", epochStart, nowUTC); 
        </cfscript>
		<cfreturn timestamp>
	</cffunction>
    
    <cffunction name="nonceCreate" access="remote" returntype="string">
    	<cfscript>
			var uuid = createUUID(); 
			//Convert the UUID to a GUID by inserting a dash in the 23rd position 
			var nonce = insert("-", uuid, 23);
		</cfscript>
		<cfreturn nonce>
	</cffunction>
    
    <cffunction name="signatureCreate" access="public" returntype="string">
		<cfargument name="request_url" type="string" required="yes">
        <cfargument name="http_method" type="string" default="get" required="no">
        <cfset request_url_address = arguments.request_url>
        
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
                    <!--- ************************************************************ --->				
                    <!--- Add parameter to Params structure                            --->				
                    <!--- ************************************************************ --->				
                    <cfset params[ListGetAt(params_list,index)] = ListGetAt(params_list,index+1)>					
                    <cfset params[ListGetAt(params_list,index)] = Replace(params[ListGetAt(params_list,index)], "PLACEHOLDER_AMPERSAND", "&", "ALL")>	
                    <!--- restore escaped ampersand (&) symbols as non-escaped --->				
                    <cfset params[ListGetAt(params_list,index)] = Replace(params[ListGetAt(params_list,index)], "PLACEHOLDER_EQUALS", "=", "ALL")>	
                    <!--- restore escaped equals (=) symbols as non-escaped --->			
                </cfloop>					
        </cfif>
		<!--- ************************************************************ --->	
        <!--- Generate signature base string                               --->	
        <!--- ************************************************************ --->			
        
        <!--- ************************************************************ --->		
        <!--- All parameters must be URL-encoded                           --->		
        <!--- ************************************************************ --->			
    
        <cfloop list="#StructKeyList(params)#" index="key">					
            <cfset params[key] = URLEncodedFormat_3986(params[key])>			
        </cfloop>	
                                    
        <!--- ************************************************************ --->		
        <!--- Get the base string                                          --->		
        <!--- ************************************************************ --->	
                
        <cfset signature_base_string = oAuthBaseStringify(http_method,request_url_address,params)>		
                
        <!--- ************************************************************ --->	
        <!--- Generate composite signing key                               --->	
        <!--- ************************************************************ --->		
        
        <cfset composite_signing_key = #application.consumer_secret# & "&" & #application.client_secret#>		
        
        <!--- ************************************************************ --->	
        <!--- Generate the SHA1 hash                                       --->	
        <!--- ************************************************************ --->		
        
        <cfset signature = ToBase64(HMAC_SHA1(composite_signing_key,signature_base_string))>			
        
        <!--- ************************************************************ --->		
        <!--- Hash (now that we have it) must also be URL encoded          --->		
    <!--- ************************************************************ --->	
		<cfreturn signature>
	</cffunction>
   
    <cffunction name="hmac_sha1" returntype="string" access="public">  
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
 
    
    <cffunction name="URLEncodedFormat_3986" returntype="string" access="private" output="no">	
    	<cfargument name="url" type="string" required="true" />	
	
			<cfset rfc_3986_bad_chars = "%2D,%2E,%5F,%7E">	
			<cfset rfc_3986_good_chars = "-,.,_,~">	
			<cfset url = ReplaceList(URLEncodedFormat(url),rfc_3986_bad_chars,rfc_3986_good_chars)>	   
    	<cfreturn url />
    </cffunction>
    
    <cffunction name="oAuthBaseStringify" returntype="string" access="public" output="no">	
		<!--- ************************************************************ --->	
        <!--- Required parameters (http_method, base_uri, values)          --->	
        <!--- ************************************************************ --->	
        <cfargument name="http_method" type="string" required="true">	
        <cfargument name="base_uri" type="string" required="true">	
        <cfargument name="parameters" type="struct" required="true">	
        <!--- ************************************************************ --->	
        <!--- Concatenate http_method & URL-encoded base_uri               --->	
        <!--- ************************************************************ --->	
            <cfset oauth_signature_base_string = http_method & "&" & URLEncodedFormat_3986(base_uri) & "&">		
        <!--- ************************************************************ --->	
        <!--- Create sorted list of parameter keys                         --->	
        <!--- ************************************************************ --->	
            <cfset keys_list = StructKeyList(parameters)>	
            <cfset keys_list_sorted = ListSort(keys_list,"textnocase")>		
            <cfset amp = "">	
        <!--- first iteration requires no ampersand --->	
        <!--- ************************************************************ --->	
        <!--- Repeat for each parameter                                    --->	
        <!--- ************************************************************ --->	
            <cfloop list="#keys_list_sorted#" index="key">			
                <!--- ************************************************************ --->		
                <!--- Concatenate URL-encoded parameter (key/value pair)           --->		
                <!--- ************************************************************ --->		
                <cfset oauth_signature_base_string = oauth_signature_base_string & URLEncodedFormat_3986(amp & LCase(key) & "=" & parameters[key])>		
                <cfset amp = "&">	
                <!--- successive iterations require a starting ampersand --->			
            </cfloop>		
        <!--- ************************************************************ --->	
        <!--- Return with OAuth signature base string                      --->	
        <!--- ************************************************************ --->	
    	<cfreturn oauth_signature_base_string>	
    </cffunction>
    
</cfcomponent>