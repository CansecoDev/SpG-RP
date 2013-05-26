/* Multi text lines include

   Version: 1.0
   Date: 2010-03-18
   Credits: KuHS

   What it do?
   It transfers string's text into two lines.

   What it used for?
   It's used for RolePlay servers. Basically most RP servers have /me /do /b commands.
   This function can transfer typed command text into multiple lines.
*/

#include <a_samp>

forward SendClientMessageA(playerid,color,text[]);

public SendClientMessageA(playerid,color,text[])
{
	if(strlen(text) <= 68) SendClientMessage(playerid,color,text);
	else {
	    new texts[61];
	    strmid(texts,text,68,129);
   		strins(text, "-", 68, 1);
		strdel(text, 69, 129);
		SendClientMessage(playerid,color,text);
		SendClientMessage(playerid,color,texts);
	}
}