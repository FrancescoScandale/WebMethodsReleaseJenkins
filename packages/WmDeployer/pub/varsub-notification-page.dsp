<HTML><HEAD>
<META http-equiv="Pragma" content="no-cache">
<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
<META http-equiv="Expires" content="-1">
<SCRIPT src="js/webMethods.js"></SCRIPT>
<LINK href="css/webMethods.css" type="text/css" rel="stylesheet">
<BODY>
<SCRIPT language=JavaScript>
function confirmClearSubstitution() {
		return confirm("[DEP.0002.0169] Do you want to clear all substitutions? You cannot undo this action.");
	}
</SCRIPT>

<TABLE width=100%>
	<TR>
		<TD class="menusection-Deployer">%value key% > %ifvar mode equals('view')%Source Values%else%Target Substitutions%endif%</TD>
	</TR>
</TABLE>

<TABLE width="100%">

<!- SaveMultiple -> 
%ifvar action equals('saveMultiple')%
	<!- All fields on form ->
	%invoke wm.deployer.gui.UIVarsub:saveVarSubItemForMultipleServers%
		%include error-handler.dsp%

	%onerror%
		%loop -struct%
			<tr><td>%value $key%=%value%</td></tr>
		%endloop%
	%end invoke%
%end if%

<!- Save -> 
%ifvar actionButton equals('Save Substitutions')%
	<!- All fields on form ->
	%invoke wm.deployer.gui.UIVarsub:saveVarSubItem%
		%include error-handler.dsp%

	%onerror%
		%loop -struct%
			<tr><td>%value $key%=%value%</td></tr>
		%endloop%
	%end invoke%
%end if%

<!- Clear -> 
%ifvar actionButton equals('Clear Substitutions')%
	<!- All fields on form ->
	%invoke wm.deployer.gui.UIVarsub:removeVarSubItem%
		%include error-handler.dsp%

	%onerror%
		%loop -struct%
			<tr><td>%value $key%=%value%</td></tr>
		%endloop%
	%end invoke%
%end if%
</TABLE>


%ifvar /mode equals('edit')%
%invoke wm.deployer.gui.UIVarsub:getVarSubAdapterNotification%
	%include error-handler.dsp%
	%onerror%
		%loop -struct%
			<tr><td>%value $key%=%value%</td></tr>
		%endloop%
	%end invoke%
%end if%

%ifvar /mode equals('assetListing')%
%invoke wm.deployer.gui.UIVarsub:getVarSubAdapterNotificationByAsset%
	%include error-handler.dsp%
	%onerror%
		%loop -struct%
			<tr><td>%value $key%=%value%</td></tr>
		%endloop%
	%end invoke%
%end if%

<TABLE width=100%>
%comment%
	<FORM name="properties" action="under-construction.dsp" method="POST">
%endcomment%
	<FORM NAME="properties" action="varsub-notification-page.dsp" method="POST">
		<INPUT type="hidden" name="projectName" value="%value projectName%">
		<INPUT type="hidden" name="deploymentMapName" value="%value deploymentMapName%">
		<INPUT type="hidden" name="deploymentSetName" value="%value deploymentSetName%">
		<INPUT type="hidden" name="sourceServerAlias" value="%value sourceServerAlias%">
		<INPUT type="hidden" name="targetServerAlias" value="%value targetServerAlias%">
		<INPUT type="hidden" name="key" value="%value key%">
		<INPUT type="hidden" name="varSubItemType" value="%value varSubItemType%">
		<INPUT type="hidden" name="packageName" value="%value packageName%">
		<INPUT type="hidden" name="mode" value="edit">
		<INPUT type="hidden" name="service" value="%value service%">
		<INPUT type="hidden" name="pluginType" value="%value pluginType%">
		<INPUT type="hidden" name="action">
		<INPUT type="hidden" name="listOfTargetServerAlias" value="%value listOfTargetServerAlias%">

	<TR>
		<TD><IMG SRC="images/blank.gif" height=10 width=10></TD>
		<TD>
		<TABLE class="tableForm">

			<tr>
				<td class="heading" colspan="2">Details for %value key%</td>
			</tr>

			<!- Interval ->
			<tr><td class="evenrow">Interval (seconds) </td>
				<td class="evenrow-l">
			
					<input name="notificationInterval" value="%value /varSubItem/notificationInterval%" size=20><b>%value /currentItem/notificationInterval%</b>
			
				</td>
			</tr>

			<!- Overlap (boolean) ->
			<tr><td class="oddrow">Overlap </td>
				<td class="oddrow-l">

					<SELECT size="1" name="notificationOverlap">
						<OPTION VALUE=""></OPTION>
						<OPTION %ifvar /varSubItem/notificationOverlap equals('true')% selected %endif% value="true">true</OPTION>
						<OPTION %ifvar /varSubItem/notificationOverlap equals('false')% selected %endif% value="false">false</OPTION>
					</SELECT><b>%value /currentItem/notificationOverlap%</b>
				</td>
			</tr>

			<!- Immediate (boolean) ->
			<tr><td class="evenrow">Immediate </td>
				<td class="evenrow-l">
					<SELECT size="1" name="notificationImmediate">
						<OPTION VALUE=""></OPTION>
						<OPTION %ifvar /varSubItem/notificationImmediate equals('true')% selected %endif% value="true">true</OPTION>
						<OPTION %ifvar /varSubItem/notificationImmediate equals('false')% selected %endif% value="false">false</OPTION>
					</SELECT><b>%value /currentItem/notificationImmediate%</b>
				</td>
			</tr>

			%ifvar /mode equals('edit')%
			<tr>
				<td colspan="1" class="action">
				<input type="submit" name="actionButton" value="Save Substitutions"> </td>
				<td colspan="1" class="action">
				<input onclick="return confirmClearSubstitution();" type="submit" name="actionButton" value="Clear Substitutions"> </td>
			</tr>
			%endif%
		</table>
		</td>
	</TR>
	</FORM>
</TABLE>
</BODY>
</HTML>
