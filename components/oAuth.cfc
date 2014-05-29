<cfcomponent displayname="oAuth" >

	<CFFUNCTION NAME="echo" access="remote" returntype="void" output="true" >
    	<!--- We should get back a URL code that we will feed to the authorizationCode method --->
        <cfif isDefined("url.code")>
        	<!---<cfdump var="#url#" abort>--->
        	<!--- Its best to lock session vars to prevent conflicts from deadlocks --->
            <cflock scope="session" timeout="5">
				<cfset session.GoogleAPI.code = "#url.code#">
                <cfset session.GoogleAPI.state = "#url.state#">
            </cflock>
        <cfelseif isDefined("url.error")>
        	<!--- You can add error tracking in Application.cfc(onError) and build a error page etc. --->
            <cflock scope="session" timeout="5">
            	<cfset session.GoogleAPI.error = '#url.error#'>
            </cflock>
        </cfif>
        <cflocation url="#application.redirect#">
    </CFFUNCTION>
        
    <CFFUNCTION NAME="authorizationCode"  access="remote" returntype="struct" output="false" >
    	<cfargument name="code" required="yes"> 
        <cfargument name="Client_ID" required="yes">
        <cfargument name="Client_secret" required="yes">
        <cfargument name="redirect_uri" required="yes">
        
  		<!--- Calls out to Google oAuth to get the client_token and refresh_token --->
    	<cfhttp method="post" url="https://accounts.google.com/o/oauth2/token" result="authCodes">
        	<cfhttpparam type="formfield" name="code" value="#arguments.code#">
        	<cfhttpparam type="formfield" name="client_id" value="#arguments.Client_ID#">
            <cfhttpparam type="formfield" name="client_secret" value="#arguments.Client_secret#">
            <cfhttpparam type="formfield" name="redirect_uri" value="#arguments.redirect_uri#">
            <cfhttpparam type="formfield" name="grant_type" value="authorization_code">
        </cfhttp>

        <!--- Active Listener --->
    	<cfif isDefined("authCodes.fileContent")>
         <cfset theData=REReplace(authCodes.FileContent,  
                    "^\s*[[:word:]]*\s*\(\s*","")> 
            <cfset theData=REReplace(theData, "\s*\)\s*$", "")> 
             <cfdump var="#thedata#">
            <!--- Test to make sure you have JSON data. ---> 
            <cfif !IsJSON(theData)> 
                <h3>The URL you requested does not provide valid JSON</h3> 
             	
            <!--- If the data is in JSON format, deserialize it. ---> 
            <cfelse> 
                <cfset cfData=DeserializeJSON(theData)>
                <cfdump var="#cfData#">
                	<!--- Its best to lock session vars to prevent conflicts from deadlocks --->
                   <cflock scope="session" timeout="5">
						<cfset session.GoogleAPI.access_token=cfData.access_token> 
                        <cfset session.GoogleAPI.expires_in=cfData.expires_in> 
                        <cfset session.GoogleAPI.token_type=cfData.token_type> 
                        <cfif isDefined("cfData.refresh_token")>
                        	<cfset session.GoogleAPI.refresh_token=cfData.refresh_token>
                        </cfif>
                        <cfif isDefined("cfData.id_token")>
                        	<cfset session.GoogleAPI.id_token=cfData.id_token>
                        </cfif>
                   </cflock>
          </cfif>
       </cfif>         
      
         <!--- From here, if everything goes well you have about 1 hour to use the access_token --->
		 <!---  otherwise you will need to refresh it with the refreshToken() method.  This is also checked --->
		 <!--- in Application.cfc onError method. --->
         <cfreturn session.GoogleAPI>
    </CFFUNCTION>
    
    <CFFUNCTION NAME="refreshToken" access="remote" returntype="void" output="false" >
    	<!--- Calls out to Google oAuth to refresh the tokens --->
    	<cfhttp method="post" url="https://accounts.google.com/o/oauth2/token" result="refresh">
        	<cfhttpparam type="formfield" name="client_id" value="#application.Client_ID#">
            <cfhttpparam type="formfield" name="client_secret" value="#application.Client_secret#">
            <cfhttpparam type="formfield" name="refresh_token" value="#session.GoogleAPI.refresh_token#">
            <cfhttpparam type="formfield" name="grant_type" value="refresh_token">
        </cfhttp>
        
       	<cfif isDefined("refresh.fileContent")>
        <cfset theData=REReplace(refresh.FileContent,  
                    "^\s*[[:word:]]*\s*\(\s*","")> 
            <cfset theData=REReplace(theData, "\s*\)\s*$", "")> 
             
            <!--- Test to make sure you have JSON data. ---> 
            <cfif !IsJSON(theData)> 
                <h3>The URL you requested does not provide valid JSON</h3> 
             
            <!--- If the data is in JSON format, deserialize it. ---> 
            <cfelse> 
                <cfset cfData=DeserializeJSON(theData)>
                	<!---Its best to lock session vars to prevent conflicts from deadlocks--->
                   <cflock scope="session" timeout="5">
						<cfset session.GoogleAPI.access_token=cfData.access_token> 
                        <cfset session.GoogleAPI.expires_in=cfData.expires_in> 
                        <cfset session.GoogleAPI.token_type=cfData.token_type> 
                        <cfif isDefined("cfData.refresh_token")>
                        	<cfset session.GoogleAPI.refresh_token=cfData.refresh_token>
                        </cfif>
                   </cflock>
            </cfif>
         <cfelse>
          <cfdump var="No Data Returned">
         </cfif>
         
    </CFFUNCTION>
    
</cfcomponent>