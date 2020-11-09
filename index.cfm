<link href="/css/style.css" media="all" rel="stylesheet" type="text/css" />

<body>
		<div>
        	<div id="leftTop">
                <h2>Google oAuth 2.0 Connector for ColdFusion</h2>
                
                <div id="footer">
            		<p>This site demonstrates <a href='http://code.google.com/apis/accounts/docs/OAuth2Login.html'>Google's OAuth 2.0 login support</a>. It's a prototype and should be treated that way.</p>
                	<img src="http://code.google.com/appengine/images/appengine-silver-120x30.gif" alt="Powered by Google App Engine" />
                   
            	</div>
                <div></div>
            </div>
            	
            	<div id="rightTop" align="right">
                	<div style=" padding:0 12px 0 12px;width:400px;border: medium solid #eee;">
                    
                     </div>
                     <div style="padding:0 12px 0 12px;width:400px; text-align:right;">
                     
                     </div>
                </div>
                <div style="position:absolute; right:25%;">

						
                </div>
            <div class="clear">
            
            </div>
        </div>
        <div id="container">
        	<div style="padding-left:14px;"><h3>Testing Harness</h3><em>We adhere strictly to Google's API policy and, as such, do not permanently store any information generated in this test harness.</em>  <a href="http://code.google.com/apis/terms/index.html" target="_blank">Google APIs Terms of Service</a></div>
              <div id="left">
                <cfif isDefined("session.GoogleAPI.code")>
                    <cfoutput>
                     
                    <h3>Oauth 2 Functions (click in left to right order)</h3>
                    <table width="100%" cellpadding="2">
                    	<tr>
                        	<td>
                            	<cfif isDefined("session.GoogleAPI.ACCESS_TOKEN")>
                                	Authorization Code Received
                                <cfelse>
                                <a href="/google/oauth/action.cfm?fn=authorizationCode">
                                   <b>DO FIRST (primero) -</b> Get Authorization Code
                                </a>
                                </cfif>
                        	</td>
                        
                        	<td>
                            	<cfif isDefined("session.GoogleAPI.access_token")>
                                	<cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.email")>
                                    	Validated User Information Received
                                    <cfelse>
                                        <a href="/google/oauth/action.cfm?fn=getValidatedUserInfo">
                                          <b>DO SECOND (segunda) -</b> Get Validated User Information
                                        </a>
                                    </cfif>
                                </cfif>	
                        	</td>
                        	
                            <td>
                                <a href="/google/oauth/action.cfm?fn=refreshToken">
                                    Refresh Token
                                </a>
                            </td>
                     	</tr>
                     </table>
                     
                     <h3>Contact Functions</h3>
						 <cfif isDefined("session.GoogleAPI.access_token")>
                            <a href="/google/oauth/action.cfm?fn=getMyLatestContacts">
                                Get Contacts
                            </a>
                         </cfif>
                     <h3>Calendar Functions</h3>
                      <table width="100%" cellpadding="2">
                    	<tr>
                        	<td>
								<cfif isDefined("session.GoogleAPI.access_token")>
                                    <a href="/google/oauth/action.cfm?fn=getMyLatestCalendar">
                                       <b>OPTIONAL (but recommended)</b> - Authorize Calendar Access</a><br>
                                       The API doc says you must authorize calendar access, but we have 
                                       found it works without it.
                                    
                                </cfif>
                            </td>
                            
                            <td>
								<cfif isDefined("session.GoogleAPI.access_token")>
                                	<cfif isdefined("session.GoogleAPI.CALENDARMETA.ETAG")>
                                    	Calendar Meta Data Received
                                    <cfelse>
                                        <a href="/google/oauth/action.cfm?fn=getMyCalendarMeta">
                                            <b>REQUIRED to interact with the claendar</b> - Get Calendar Meta Data
                                        </a>
                                    </cfif>
                                </cfif>
                        	</td>
                            
                            <td>
                            	<cfif isDefined("session.GoogleAPI.calendarMeta.id")>
                                    <a href="/google/oauth/action.cfm?fn=getMyCalendarList">
                                        Get Calendar List
                                    </a>
                                </cfif>
                            </td>
                            
                            <td>
                            	<cfif isDefined("session.GoogleAPI.calendarMeta.id")>
                                    <a href="/google/oauth/action.cfm?fn=getMyCalendarEvents">
                                        List All Calendar Events
                                    </a>
                                </cfif>
                        	</td>
                        </tr>
                        </table>
                        <cfif isDefined("session.GoogleAPI.calendarMeta.id")>
                        <h3>Create Calendar Event</h3>
                            <table>
                            <cfform method="post" action="/google/oauth/action.cfm?fn=createMyCalendarEvent">
                                <tr><td>Event Name:</td><td><cfinput name="summary" type="text"></td></tr>
                                <tr><td>Event Desc:</td><td><cfinput name="description" type="text"></td></tr>
                                <tr><td>Start Date:</td><td><cfinput name="startDate" type="text">yyyy-mm-dd</td></tr>
                                <tr><td>Start Time:</td><td><cfinput name="startTime" type="text">23:59</td></tr>
                                <tr><td> End  Date:</td><td><cfinput name="EndDate" type="text">yyyy-mm-dd</td></tr>
                                <tr><td> End  Time:</td><td><cfinput name="EndTime" type="text">23:59</td></tr>
                                <tr><td><cfinput type="submit" name="subnit" value="submit"></td></td>
                            </cfform>
                            </table>
                        <cfelse>
                        	<h3>Create Calendar Event Happens Here</h3>
                            You need to get the calendar meta data to see this
                        </cfif>
                        
                        <cfif isDefined("session.GoogleAPI.calendarMeta.etag")>
                      		<h3>Insert Gmail Contact</h3>
                                <table width="600">
                                <cfform method="post" action="/google/oauth/action.cfm?fn=createNewContact">
                                    <tr><td width="200">**Last Name:</td><td><cfinput required="yes" message="The first name is required" name="firstName" type="text"></td></tr>
                                    <tr><td width="200">**First Name:</td><td><cfinput required="yes" message="The last name is required" name="lastName" type="text"></td></tr>
                                    <tr><td width="200">Job Title:</td><td><cfinput name="organization_Title" type="text"></td></tr>
                                    <tr><td width="200">Company Name:</td><td><cfinput name="organization_Name" type="text"></td></tr>
                                    <tr><td width="200">Work Address:</td><td><cfinput name="work_address1" type="text"></td></tr>
                                    <tr><td width="200">Work City:</td><td><cfinput name="work_city" type="text"></td></tr>
                                    <tr><td width="200">Work State:</td><td><cfinput name="work_state" type="text"></td></tr>
                                    <tr><td width="200">Work Postal Code:</td><td><cfinput name="work_postal_code" type="text"></td></tr>
                                    <tr><td width="200">Work Country:</td><td><cfinput name="work_country" value="United States" type="text"></td></tr>
                                    <tr><td width="200">Work Email:</td><td><cfinput name="work_email" type="text"></td></tr>
                                    <tr><td width="200">Home Address:</td><td><cfinput name="home_address1" type="text"></td></tr>
                                    <tr><td width="200">Home City:</td><td><cfinput name="home_city" type="text"></td></tr>
                                    <tr><td width="200">Home State:</td><td><cfinput name="home_state" type="text"></td></tr>
                                    <tr><td width="200">Home Postal Code:</td><td><cfinput name="home_postal_code" type="text"></td></tr>
                                    <tr><td width="200">Home Country:</td><td><cfinput name="home_country" value="United States" type="text"></td></tr>
                                    <tr><td width="200">Home Email:</td><td><cfinput name="home_email" type="text"></td></tr>
                                    <tr><td width="200">Work Phone:</td><td><cfinput name="work_phone" type="text"></td></tr>
                                    <tr><td width="200">Home Phone:</td><td><cfinput name="home_phone" type="text"></td></tr>
                                    <tr><td width="200">Mobile Phone:</td><td><cfinput name="mobile_phone" type="text"></td></tr>
                                    <tr><td width="200">Fax Phone:</td><td><cfinput name="fax_phone" type="text"></td></tr>
                                    <tr><td width="200">Other Phone:</td><td><cfinput name="other_phone" type="text"></td></tr>
                                    <tr><td width="200"><cfinput type="submit" name="submit" value="submit"></td></td>
                                </cfform>
                                </table>
                        <cfelse>
                        	<h3>Insert Calendar Contact Happens Here</h3>
                            You need to get the calendar meta data to see this
                        </cfif>
                    </cfoutput>
                <cfelse>
                    <!--- You must define the scope for oAuth.  This will get ti done for what we shipped for you --->
                    <cfset scopeURL = "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.google.com/m8/feeds https://www.googleapis.com/auth/calendar.readonly https://www.googleapis.com/auth/calendar">
             	<div style="color:##000; margin-left:4px; margin-right:4px;">
                	<h3>To Access the Testing Harness</h3>
                    <ul>
                    	<li>Create a <a href="https://accounts.google.com/" target="_blank">Gmail Account</a></li>
                        <li>Log in to Gmail through this portal*</li>
                        <li>At any time after the authentication you may clear the authenticated tokens by concatenating killSession=1 to the URL or by simply closing the browser.</li>
                    </ul>
                    <span><em>* The login process happens at Google's endpoint and we have no access to your username or password.</em> </span>
                    <br>
                    <br>
                    <br>
                    <cftooltip sourceForTooltip="/includes/oauthprocess.cfm" showdelay="150" hideDelay="1000" autoDismissDelay="10000"><strong style="color:##f63;"> [ Rollover to View Process</strong></cftooltip>
                    ]
             	</div>
                <br>
                <br>
                 <cfoutput>
                        <a class="button"  href="https://accounts.google.com/o/oauth2/auth?scope=#URLEncodedFormat(scopeURL)#&state=%2Fprofile&client_id=#application.client_id#&redirect_uri=#application.redirect_uri#&response_type=code&access_type=offline&approval_prompt=force" style="font-size:14px; padding:4px 0 4px 0; border:medium ##FFF;"><span>Step 1 - Click Here to Login Using your Gmail Account Credentials</span></a>
                    </cfoutput> 
            </cfif> 
            </div>
            
            <div id="right">
                <cfif isDefined("session.GoogleAPI.code")>
                
                <cfoutput>
                
                <table width="500" align="center">
                    <tr>
                    	<td colspan="2"><h3>Session Variables</h3></td>
                    </tr>
                    <tr bgcolor="##000000">
                    	<td colspan="2"><b style="color:##fff;">oAuth Tokens</b></td>
                    </tr>
                    
                    <cfif isDefined("session.GoogleAPI.state")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	STATE:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.state#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.ACCESS_TOKEN")>
                    	<tr>
                        	<td>
                            	ACCESS_TOKEN:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.ACCESS_TOKEN#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.CODE")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	CODE:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.CODE#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.EXPIRES_IN")>
                    	<tr>
                        	<td>
                            	EXPIRES_IN:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.EXPIRES_IN#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.ID_TOKEN")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	**NEW!** ID_TOKEN:
                            </td>
                            
                            <td style="word-wrap:break-word !important; width: 400px;">
                            	#session.GoogleAPI.ID_TOKEN#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.REFRESH_TOKEN")>
                    	<tr>
                        	<td>
                            	REFRESH_TOKEN:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.REFRESH_TOKEN#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.TOKEN_TYPE")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	TOKEN_TYPE:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.TOKEN_TYPE#
                            </td>
                        </tr>
                    </cfif>
                    <tr bgcolor="##000000">
                    	<td colspan="2"><b style="color:##fff;">Validated User Information</b></td>
                    </tr>
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.email")>
                    	<tr>
                        	<td>
                            	 EMAIL:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.VALIDATEDUSERINFO.email#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.family_name")>
                    	<tr bgcolor="##CCCCCC">
                        	<td>
                            	 FAMILY_NAME:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.VALIDATEDUSERINFO.family_name#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.gender")>
                    	<tr>
                        	<td>
                            	 GENDER:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.VALIDATEDUSERINFO.gender#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.given_name")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	 GIVEN_NAME:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.VALIDATEDUSERINFO.given_name#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.id")>
                    	<tr>
                        	<td>
                            	 ID:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.VALIDATEDUSERINFO.id#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.locale")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	 LOCALE:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.VALIDATEDUSERINFO.locale#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.name")>
                    	<tr>
                        	<td>
                            	 NAME:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.VALIDATEDUSERINFO.name#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.picture")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	 PICTURE:
                            </td>
                            
                            <td>
                            	<cfif len(session.GoogleAPI.VALIDATEDUSERINFO.picture) gt 0><img src="#session.GoogleAPI.VALIDATEDUSERINFO.picture#"></cfif>
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.timezone")>
                    	<tr>
                        	<td>
                            	 TIMEZONE:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.VALIDATEDUSERINFO.timezone#
                            </td>
                        </tr>
                    </cfif>
                    
                    <cfif isDefined("session.GoogleAPI.VALIDATEDUSERINFO.verified_email")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	 VERIFIED_EMAIL:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.VALIDATEDUSERINFO.verified_email#
                            </td>
                        </tr>
                    </cfif>
                    <tr bgcolor="##000000">
                    	<td colspan="2"><b style="color:##fff;">Calendar Meta Data</b></td>
                    </tr>
                    <cfif isDefined("session.GoogleAPI.CALENDARMETA.ETAG")>
                    	<tr>
                        	<td>
                            	CALENDARMETA ETAG:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.CALENDARMETA.ETAG#
                            </td>
                        </tr>
                    </cfif>
                    <cfif isDefined("session.GoogleAPI.CALENDARMETA.ID")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	CALENDARMETA ID:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.CALENDARMETA.ID#
                            </td>
                        </tr>
                    </cfif>
                    <cfif isDefined("session.GoogleAPI.CALENDARMETA.KIND")>
                    	<tr>
                        	<td>
                            	CALENDARMETA KIND:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.CALENDARMETA.KIND#
                            </td>
                        </tr>
                    </cfif>
                    <cfif isDefined("session.GoogleAPI.CALENDARMETA.SUMMARY")>
                    	<tr bgcolor="##CCCCCC"
                            	>
                        	<td>
                            	CALENDARMETA SUMMARY:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.CALENDARMETA.SUMMARY#
                            </td>
                        </tr>
                    </cfif>
                    <cfif isDefined("session.GoogleAPI.CALENDARMETA.TIMEZONE")>
                    	<tr>
                        	<td>
                            	CALENDARMETA TIMEZONE:
                            </td>
                            
                            <td>
                            	#session.GoogleAPI.CALENDARMETA.TIMEZONE#
                            </td>
                        </tr>
                    </cfif>
                </table>
                </cfoutput>
                </cfif>	
            </div>
          <div class="clear"></div>
</div><!-- container -->
