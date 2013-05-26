/* *****************************************
 Name: Server Side money Script [FS]
 By: X_Cutter
 Date: September 2009 UPDATED October 2009
 Use: Avoid money hacks
 Version: 3
 SA-MP: Should work on any version.
 Made for: 0.2X / 0.3a
***************************************** */
/*CREDITS: Romanius for the callback hooking idea*/


/*
 Use: Include this to your gamemode right under #include <a_samp> by
 writing #include <servermoneyFS>
 Make sure you have installed the GM include to your GM!
 If you didn't this won't work.
*/


stock GetPlayerMoneyEx(playerid)
{
	return CallRemoteFunction("GetPlayerMoneyEx","i",playerid);
}
stock GivePlayerMoneyEx(playerid,cashgiven)
{
	return CallRemoteFunction("GivePlayerMoneyEx","ii",playerid,cashgiven);
}
stock ResetPlayerMoneyEx(playerid)
{
	return CallRemoteFunction("ResetPlayerMoneyEx","i",playerid);
}

#define GetPlayerMoney GetPlayerMoneyEx
#define GivePlayerMoney GivePlayerMoneyEx
#define ResetPlayerMoney ResetPlayerMoneyEx
