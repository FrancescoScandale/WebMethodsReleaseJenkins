<?xml version='1.0'?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
    <head>
        <title>Asset Publisher - Configuration</title>
        <meta http-equiv="Pragma" content="no-cache">
        <meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
        <meta http-equiv="Expires" content="-1">
        <link rel="stylesheet" type="text/css" href="../WmRoot/webMethods.css"></link>
    	%ifvar webMethods-wM-AdminUI%
			<link rel="stylesheet" TYPE="text/css" HREF="../WmRoot/webMethods-wM-AdminUI.css"></link>
			<script>webMethods_wM_AdminUI = 'true';</script>
		%endif%
        <script type="text/javascript" src="../WmRoot/webMethods.js"></script>
        <script language="JavaScript1.2">
            //setHelpPage("/WmAssetPublisher/configuration.dsp", "Config.html");
        </script>
    </head>
    <BODY onLoad="setNavigation('/WmAssetPublisher/configuration.dsp', '/WmRoot/doc/OnlineHelp/wwhelp.htm?context=is_help&topic=IS_Settings_Metadata_Config');">
        %include configuration-table.dsp%
    </body>
</html>
