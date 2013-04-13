<cfcomponent output="no">
	<!--- Application name, should be unique --->
	<cfset this.name = 'GoogleOauthAPI'>
	<!--- How long application vars persist --->
	<cfset this.applicationTimeout = CreateTimeSpan(0,1,0,0)>
	<!--- Should client vars be enabled? --->
	<cfset this.clientManagement = "No">
	<!--- Where should cflogin stuff persist --->
	<cfset this.loginStorage = "Cookie">
	<!--- Should we set cookies on the browser? --->
	<cfset this.setClientCookies = true>
	<!--- should cookies be domain specific, ie, *.foo.com or www.foo.com --->
	<cfset this.setDomainCookies = true>
	<!--- should we try to block 'bad' input from users --->
	<cfset this.scriptProtect = "all">
	<!--- should we secure our JSON calls? --->
	<cfset this.secureJSON = false>
	<!--- Should we use a prefix in front of JSON strings? --->
	<cfset this.secureJSONPrefix = "">
	<!--- define custom coldfusion mappings. Keys are mapping names, values are full paths  --->
	<cfset this.mappings = structNew()>
	<!--- define a list of custom tag paths. --->
	<cfset this.customtagpaths = "">
    <!--- Should we even use sessions? --->
	<cfset this.sessionManagement = true>
	<!--- How long do session vars persist? --->
	<cfset this.sessionTimeout = createTimeSpan(0,0,20,0)>
    
    
    <cffunction name="onApplicationStart" returnType="boolean" output="false"> 
    	<cfset application.oAuth = createObject("component","components.oAuth").init()>
    	<cfset application.googleContacts = createObject("component","components.googleContacts").init()>
       <cfset application.googleCalendars = createObject("component","components.googleCalendars").init()>
       <cfset application.requestFunctions = createObject("component","components.requestFunctions").init()>
         
        <!--- CHANGE TO YOUR VALUES GET THEM AT THE LINK BELOE--->
		<!--- https://code.google.com/apis/console/? (click the link that says API access...you can create them there--->
        <cfset application.Client_ID = ''> 
        <cfset application.Client_secret = ''>
        <cfset application.redirect_uri = 'http://yourURL/components/oauth.cfc?method=echo'> 
        <!---<cfset application.redirect_uri = 'https://www-opensocial.googleusercontent.com/api/people/@me/@self'>---> 
        <cfset application.Consumer_Key = ''>
        <cfset application.Consumer_secret = ''>
        <!--- Use API keys to identify your project when you do not need to access user data --->
        <cfset application.API_key = ''>
        <cfset application.Obsolete_key = ''>
        
        <cfreturn true>
    </cffunction>

	<CFFUNCTION name="onRequestStart" output="false">
    	<!--- If you change the cfcs you must re compile the class files created in createObject line 31 --->
        <!--- The easiest way to do this is add reinit=1 to the url and run it.   --->
		 <!--- Otherwise you will need to restart the CF or JRun service --->
        <cfif structKeyExists(url, "reinit")>
			<cfset onApplicationStart()>
		</cfif>
    </CFFUNCTION>
    
    <!--- Runs on error --->
	<cffunction name="onError" returnType="void" output="true">
    <cfargument name="Exception" type="any" required=true/> 
    <cfargument type="String" name="EventName" required=true/> 
    <!--- Log all errors. ---> 
    <cflog file="#This.Name#" type="error"  
            text="Event Name: #Arguments.Eventname#" > 
    <cflog file="#This.Name#" type="error"  
            text="Message: #Arguments.Exception.message#"> 
    <!--- <cflog file="#This.Name#" type="error"  
        text="Root Cause Message: #Arguments.Exception.rootcause#"> 
    Display an error message if there is a page context. ---> 
    <cfif NOT (Arguments.EventName IS "onSessionEnd") OR  
            (Arguments.EventName IS "onApplicationEnd")> 
        <cfoutput> 
            <h2>An unexpected error occurred.</h2> 
            <p>Please provide the following information to technical support:</p> 
            <p>Error Event: #Arguments.EventName#</p> 
            <p>Error details:<br> 
            <cfdump var="#Arguments.Exception#" abort></p> 
        </cfoutput> 
    </cfif> 
	</cffunction>
    
    <cffunction name="onRequestEnd" output="yes">
		<div id="footer">
		<p>This site demonstrates <a href='http://code.google.com/apis/accounts/docs/OAuth2Login.html'>Google's OAuth 2.0 login support</a>. It's a prototype and should be treated that way.</p>
			<img src="http://code.google.com/appengine/images/appengine-silver-120x30.gif" alt="Powered by Google App Engine" />
    	</div>
    		<!---<cfdump var="#session#">
			<cfdump var="#application#">--->
    </cffunction>
</cfcomponent>