<div>This is a structure dump. These values are not stored in session on the testing harness.<br /><a href="index.cfm"><h1><-- Go Back to the Harness</h1></a> </div>
<cfif isDefined("url.fn")>
	<cfswitch expression="#url.fn#">
    	<cfcase value="authorizationCode">

        	<cfset authCode = application.oAuth.authorizationCode(
																  "#session.GoogleAPI.code#", 
																  "#application.Client_ID#", 
																  "#application.Client_secret#", 
																  "#application.redirect_uri#"
																 )>
            <cflocation url="index.cfm">
        </cfcase>
        
        <cfcase value="getValidatedUserInfo">
        	
        	<cfset userInfo = application.googleContacts.getValidatedUserInfo(session.GoogleAPI.access_token, application.Consumer_Key)>
            
            <cflocation url="index.cfm">
        </cfcase>
    
    	<cfcase value="getMyLatestContacts">
			<h3>Contacts</h3>
               
                    <cfset contactsFeed = application.googleContacts.getMyContacts(session.GoogleAPI.access_token)>

            <!---<cflocation url="index.cfm">--->
            <cfdump var="#contactsFeed#">
        </cfcase>
        
        <cfcase value="getMyCalendarList">
            
            <h3>Calendar List</h3>
               
                <!---Establish contact with calendar api--->
            		<cfset calendarFeed = application.googleCalendars.retrieveCalendarList(session.GoogleAPI.access_token, application.API_Key)>
              <!--- This is a deserialized JSON object --->     
            <cfdump var="#calendarFeed#">
        </cfcase>
        
        <cfcase value="createMyCalendarEvent">

            <h3>Create Calendar Event</h3>
            <!---RFC DateTime Looks like this: 201-12-08T22:47:31-05:00--->
            <!---The -05:00 at the end of the time indicates Eastern Standard Time (GMT - 5 hours).  You may adjust this according to your timezone--->
            <cfset googleStartDateTime = '#form.startDate#T#form.startTime#:00-05:00'>
            <cfset googleEndDateTime = '#form.endDate#T#form.endTime#:00-05:00'>
               
                <!---Establish contact with calendar api--->
            		<cfset calendarEvent = application.googleCalendars.reminderCalendarEventInsert(form.summary, form.description, googleStartDateTime, googleEndDateTime, session.GoogleAPI.access_token, application.API_Key, session.GoogleAPI.calendarMeta.id)>
            
            <cfif IsJSON(calendarEvent)>
            	<!--- Returns a JSON Object --->
            	<cfdump var="#DeserializeJSON(calendarEvent)#">
            <cfelse>
            	<!--- Returns an ERROR --->
            	<cfdump var="#calendarEvent#">
            </cfif>
        </cfcase>
        
        <cfcase value="createNewContact">
            
            <h3>Create New Contact</h3>
            
               
                <!---Establish contact with calendar api--->
            		<cfset createNewContactEvent = application.googleContacts.insertContact(
																							form.firstName, 
																							form.lastName, 
																							form.organization_Name,
																							form.organization_Title,
																							form.work_city,
																							form.work_address1,
																							form.work_state,
																							form.work_postal_code,
																							form.work_country,
																							form.work_email,
																							form.home_city,
																							form.home_address1,
																							form.home_state,
																							form.home_postal_code,
																							form.home_country,
																							form.home_email,
																							form.work_phone,
																							form.home_phone,
																							form.mobile_phone,
																							form.fax_phone,
																							form.other_phone,
																							session.GoogleAPI.validatedUserInfo.EMAIL,
																							session.GoogleAPI.access_token
																						)>
                   
           
            <cfif IsJSON(createNewContactEvent.fileContent)>
            	<!--- Returns a JSON Object --->
            	<cfdump var="#DeserializeJSON(createNewContactEvent.fileContent)#">
            <cfelse>
            	<!--- Returns an ERROR --->
            	<cfdump var="#createNewContactEvent#">
            </cfif>
        </cfcase>
        
         <cfcase value="getMyCalendarEvents">
            
            <h3>Get Calendar Events</h3>
               
                <!---Establish contact with calendar api--->
            		<cfset eventsFeed = application.googleCalendars.listAllCalendarEvents(session.GoogleAPI.access_token, application.API_Key, session.GoogleAPI.calendarMeta.id)>
                   
            <!--- Returns a JSON Object --->
            <cfdump var="#DeserializeJSON(eventsFeed)#">
        </cfcase>
        
        <cfcase value="getMyCalendarMeta">
            
            <h3>Get Calendar Metas</h3>
                
                <!---Establish contact with calendar api--->
            		<cfset metaFeed = application.googleCalendars.retrieveCalendarMetaData(session.GoogleAPI.access_token, application.API_Key)>
                   
            
            <cflocation url="index.cfm">
        </cfcase>
        
		<cfcase value="getMyLatestCalendar">
            
            <h3>Get My Calendar Info</h3>
                
                <!---Establish contact with calendar api--->
            		<cfset calendarFeed = application.googleCalendars.authCalendar(session.GoogleAPI.access_token, application.Consumer_Key)>
            
            <cfdump var="#calendarFeed.Filecontent#">
        </cfcase>
        
        <cfcase value="refreshToken">
            
            <h3>Get Calendar Metas</h3>
                
                <!---Establish contact with calendar api--->
            		<cfset refresh = application.oAuth.refreshToken()>
                    
            <cflocation url="index.cfm">
        </cfcase>
        
	</cfswitch>
</cfif>