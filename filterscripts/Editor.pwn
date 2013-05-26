#include <a_samp>
#include <zcmd> // credits to zeek ( I think ) for this include
#include <sscanf2> // credits to Y-Less for this plugin

#define COLOR   		0xAFAFAFAA
#define MAX     		100 //effective max players, change this to your value
#define SAVE_PATH       "attached/" //in scriptfiles
#define REFRESH_RATE    100 //refresh rate in ms
// ----------------------------------------------------------
//
//         Attached Object Editor
//
//       By Racheal (c) Jan 2011
//
// -----------------------------------------------------------
new bool:working[MAX];
new timer[MAX];
enum holding { model,bone,Float:ox,Float:oy,Float:oz,Float:rx,Float:ry,Float:rz,Float:sx,Float:sy,Float:sz };
new stats[MAX][6][holding];
new Float:ppos[MAX][3];
new Float:cam[MAX][3];
new apos[MAX] = {180, ... };
new bool:frozen[MAX];
new Float:close[MAX] = {3.0, ... };
new pindex[MAX];
new mode[MAX];
new bool:camera[MAX];
new Text:help = Text:INVALID_TEXT_DRAW;
new Text:offset,Text:rotate,Text:scale,Text:legend,Text:edit;
new Text:dindex[5];

forward display(playerid);
stock ContainsValidCharacters(string[])
{
    if (
	(strfind(string, "[") != -1) ||
	(strfind(string, "]") != -1) ||
	(strfind(string, "&") != -1) ||
	(strfind(string, "'") != -1) ||
	(strfind(string, "`") != -1) ||
	(strfind(string, "~") != -1) ||
	(strfind(string, "/") != -1) ||
	(strfind(string, "\\") != -1) ||
	(strfind(string, ":") != -1) ||
	(strfind(string, "*") != -1) ||
	(strfind(string, "?") != -1) ||
	(strfind(string, "<") != -1) ||
	(strfind(string, ">") != -1) ||
	(strfind(string, "|") != -1) ||
	(strfind(string, "\"") != -1) )
	    return 0;
	return 1;
}

stock ResetArray(playerid,index)
{
	if(!index)
	{
		for(new i = 1; i <= 5; i++)
		{
			stats[playerid][i][model] = 0;
			stats[playerid][i][bone] = 0;
			stats[playerid][i][ox] = 0.0;
			stats[playerid][i][oy] = 0.0;
			stats[playerid][i][oz] = 0.0;
			stats[playerid][i][rx] = 0.0;
			stats[playerid][i][ry] = 0.0;
			stats[playerid][i][rz] = 0.0;
			stats[playerid][i][sx] = 1.0;
			stats[playerid][i][sy] = 1.0;
			stats[playerid][i][sz] = 1.0;
		}
		return 1;
	}
	stats[playerid][index][model] = 0;
	stats[playerid][index][bone] = 0;
	stats[playerid][index][ox] = 0.0;
	stats[playerid][index][oy] = 0.0;
	stats[playerid][index][oz] = 0.0;
	stats[playerid][index][rx] = 0.0;
	stats[playerid][index][ry] = 0.0;
	stats[playerid][index][rz] = 0.0;
	stats[playerid][index][sx] = 1.0;
	stats[playerid][index][sy] = 1.0;
	stats[playerid][index][sz] = 1.0;
	return 1;
}
stock DisplayIndex(playerid, index)
{
	for(new i = 0; i < 5; i++)
	{
	    if((i+1) == index)
	    {
	        TextDrawShowForPlayer(playerid,dindex[i]);
		} else {
		    TextDrawHideForPlayer(playerid,dindex[i]);
		}
	}
	return 1;
}
public OnFilterScriptInit()
{
	new string[650];
	format(string,sizeof(string),"hold ~k~~PED_FIREWEAPON~ + Direction to move the camera~n~DIR KEYS for movement     ~k~~PED_JUMPING~/~k~~SNEAK_ABOUT~ up/down     ~k~~PED_SPRINT~ to speed up movement~n~~k~~VEHICLE_ENTER_EXIT~");
	strcat(string,"(Offset)    ~k~~PED_ANSWER_PHONE~(Rotation)     ~k~~PED_LOCK_TARGET~(Scale)    ~k~~PED_LOOKBEHIND~(Unfreeze/freeze)~n~~n~/editor(cancel)                     /index(change or edit slots)       /asave(save to file)",sizeof(string));
	strcat(string,"~n~/camera(toggle free camera)      /scale(reset scale to 1.0)          /aload(load a file)",sizeof(string));
	help = TextDrawCreate(155.0, 380.0, string);
	TextDrawLetterSize(help,0.3, 1.0);
	TextDrawUseBox(help,1);
	TextDrawBoxColor(help,0x000000DD);
	TextDrawColor(help, 0x00FF44FF);
	TextDrawFont(help,1);
	
	offset = TextDrawCreate(570.0, 360.0,"Offset");
	TextDrawLetterSize(offset,0.5, 1.3);
	TextDrawColor(offset, 0x3399FF);
	TextDrawUseBox(offset,1);
	TextDrawFont(offset,1);
	TextDrawBoxColor(offset,0x000000DD);
	
	rotate = TextDrawCreate(570.0, 350.0,"Rotation");
	TextDrawLetterSize(rotate,0.5, 1.3);
	TextDrawColor(rotate, 0x3399FF);
	TextDrawUseBox(rotate,1);
	TextDrawBoxColor(rotate,0x000000DD);
	TextDrawFont(rotate,1);
	
	scale = TextDrawCreate(570.0, 340.0,"Scale");
	TextDrawLetterSize(scale,0.5, 1.3);
	TextDrawColor(scale, 0x3399FF);
	TextDrawUseBox(scale,1);
	TextDrawBoxColor(scale,0x000000DD);
	TextDrawFont(scale,1);
	
	format(string,sizeof(string),"1-Spine~n~2-Head~n~3.Left Upper Arm~n~4.Right Upper Arm~n~5-Left Hand~n~6-Right Hand~n~7-Left Thigh~n~8-Right Thigh~n~9-Left Foot~n~");
	strcat(string,"10-Right Foot~n~11-Right Calf~n~12-Left Calf~n~13-Left Forearm~n~14-Right Forearm~n~15-Left Clavicle~n~16-Right Clavicle~n~17-Neck~n~18-Jaw",sizeof(string));
	legend = TextDrawCreate(25.0,290.0,string);
	TextDrawFont(legend,1);
	TextDrawLetterSize(legend,0.3, 0.9);
	TextDrawColor(legend, 0xFF6388FF);
	TextDrawUseBox(legend,1);
	TextDrawBoxColor(legend,0x000000DD);
	TextDrawTextSize(legend,130.0,220.0);
	
	edit = TextDrawCreate(570.0, 320,"Editing");
	TextDrawLetterSize(edit,0.5, 1.3);
	TextDrawColor(edit, 0x3399FF);
	TextDrawUseBox(edit,1);
	TextDrawBoxColor(edit,0x000000DD);
	TextDrawFont(edit,1);
	
	new number[3];
	for(new i = 0; i < 5; i++)
	{
	    format(number,sizeof(number),"%d",i+1);
	    dindex[i] = TextDrawCreate(570.0, 380.0,number);
	    TextDrawLetterSize(dindex[i],2.0, 4.0);
	    TextDrawFont(dindex[i],1);
	    TextDrawColor(dindex[i], 0x3399FF);
	}
	return 1;
}
public OnFilterScriptExit()
{
	TextDrawDestroy(help);
	TextDrawDestroy(offset);
	TextDrawDestroy(rotate);
	TextDrawDestroy(scale);
	TextDrawDestroy(legend);
	TextDrawDestroy(edit);
	for(new i = 0; i < 5; i++)
	{
	    TextDrawDestroy(dindex[i]);
	}
	for(new i = 0; i < MAX; i++)
	{
	    if(working[i])
	    {
	        TogglePlayerControllable(i,true);
	        SetCameraBehindPlayer(i);
	        for(new z = 0; z <= 4;z++)
	        {
				RemovePlayerAttachedObject(i,z);
			}
		}
	}
	return 1;
}
CMD:index(playerid,params[])
{
	if(!IsPlayerAdmin(playerid))
	{
	    SendClientMessage(playerid,COLOR,"Not authorized");
	    return 1;
	}
	if(!working[playerid])
	{
	    SendClientMessage(playerid,COLOR,"enter the editor, type /editor");
	    return 1;
	}
	if(isnull(params))
	{
	    SendClientMessage(playerid,COLOR,"{FFFFFF}/index [1-5] {AFAFAF}                - switch to exiting the object on that index");
	    SendClientMessage(playerid,COLOR,"{FFFFFF}/index [1-5] 0{AFAFAF}               - clear the object on that index");
	    SendClientMessage(playerid,COLOR,"{FFFFFF}/index [1-5] [model#] [bone]{AFAFAF} - add / change object on that index");
	    return 1;
	}
	new iindex,tmp[12],imodel,ibone;
	new string[128];
	if(sscanf(params,"iS()[12]I(2)",iindex,tmp,ibone))
	{
	    SendClientMessage(playerid,COLOR,"USAGE: /index [index 1-5] [model# / 0-clear ] [bone 1-18]");
	    return 1;
	}
	if(iindex < 1 || iindex > 5)
	{
	    SendClientMessage(playerid,COLOR,"USAGE: /index [index 1-5] [model# / 0-clear ] [bone 1-18]");
	    return 1;
	}
	if(!strlen(tmp))
	{
	    if(stats[playerid][iindex][model] == 0)
	    {
			format(string,sizeof(string),"There is no model attached to index %d",iindex);
			SendClientMessage(playerid,COLOR,string);
			return 1;
		}
		format(string,sizeof(string),"now editing index %d",iindex);
		SendClientMessage(playerid,COLOR,string);
		pindex[playerid] = iindex;
		DisplayIndex(playerid, iindex);
		return 1;
	}
	imodel = strval(tmp);
	if(imodel <= 0)
	{
	    RemovePlayerAttachedObject(playerid,(iindex - 1));
	    stats[playerid][iindex][model] = 0;
	    stats[playerid][iindex][bone] = 0;
	    
	    format(string,sizeof(string),"Attach index %d cleared",iindex);
	    RemovePlayerAttachedObject(playerid,(iindex - 1));
	    ResetArray(playerid,iindex);
		SendClientMessage(playerid,COLOR,string);
		return 1;
	}
	if(ibone < 1 || ibone > 18)
	{
	    SendClientMessage(playerid,COLOR,"Invalid bone selected 1 - 18");
	    return 1;
	}
	pindex[playerid] = (iindex);
	ResetArray(playerid,iindex);
	DisplayIndex(playerid,iindex);
	stats[playerid][iindex][model] = imodel;
	stats[playerid][iindex][bone] = ibone;
	SetPlayerAttachedObject(playerid,(pindex[playerid]-1),
		stats[playerid][pindex[playerid]][model],
		stats[playerid][pindex[playerid]][bone],
		stats[playerid][pindex[playerid]][ox],
		stats[playerid][pindex[playerid]][oy],
		stats[playerid][pindex[playerid]][oz],
		stats[playerid][pindex[playerid]][rx],
		stats[playerid][pindex[playerid]][ry],
		stats[playerid][pindex[playerid]][rz],
		stats[playerid][pindex[playerid]][sx],
		stats[playerid][pindex[playerid]][sy],
		stats[playerid][pindex[playerid]][sz]
	);
	format(string,sizeof(string),"Attached object# %d to bone %d index %d",imodel,ibone,iindex);
	SendClientMessage(playerid,COLOR,string);
	return 1;
}
	    
CMD:editor(playerid,params[])
{
	if(!IsPlayerAdmin(playerid))
	{
	    SendClientMessage(playerid,COLOR,"Not authorized");
	    return 1;
	}
	if(working[playerid])
	{
	    KillTimer(timer[playerid]);
	    
	    working[playerid] = false;
	    frozen[playerid] = false;
	    camera[playerid] = true;
	    TogglePlayerControllable(playerid,true);
	    SetCameraBehindPlayer(playerid);
        for(new z = 0; z <= 4;z++)
        {
			RemovePlayerAttachedObject(playerid,z);
		}
	    ResetArray(playerid, 0);
	    TextDrawHideForPlayer(playerid,help);
	    TextDrawHideForPlayer(playerid,offset);
	    TextDrawHideForPlayer(playerid,rotate);
	    TextDrawHideForPlayer(playerid,scale);
	    TextDrawHideForPlayer(playerid,legend);
	    TextDrawHideForPlayer(playerid,edit);
	    DisplayIndex(playerid,0);
	    if(timer[playerid])
		{
	    	KillTimer(timer[playerid]);
	    	timer[playerid] = 0;
		}
	    return 1;
	}
	new index,in_mod,in_bone;
	if(!sscanf(params,"iiI(2)",index,in_mod,in_bone))
	{
	    if(index < 1 || index > 5 || in_mod < 1 || in_bone < 1 || in_bone > 18)
		{
		    SendClientMessage(playerid,COLOR,"USAGE: /editor [index 1-5] [model#] [bone 1-18]");
		    return 1;
		}
		pindex[playerid] = index;
		DisplayIndex(playerid, index);
		ResetArray(playerid,0);
		stats[playerid][index][model] = in_mod;
		stats[playerid][index][bone] = in_bone;

		stats[playerid][index][sx] = 1.0;
		stats[playerid][index][sy] = 1.0;
		stats[playerid][index][sz] = 1.0;

		frozen[playerid] = true;

		TextDrawShowForPlayer(playerid,help);
		TextDrawShowForPlayer(playerid,legend);
		TextDrawShowForPlayer(playerid,offset);
		TextDrawShowForPlayer(playerid,edit);
		timer[playerid] = SetTimerEx("display",REFRESH_RATE,true,"i",playerid); //adjust refresh rate to your liking
		
		working[playerid] = true;
		camera[playerid] = false;
		TogglePlayerControllable(playerid,false);
		GetPlayerPos(playerid,ppos[playerid][0],ppos[playerid][1],ppos[playerid][2]);
		new Float:angle;
		GetPlayerFacingAngle(playerid,angle);
		apos[playerid] = floatround(angle,floatround_round);
		if(apos[playerid] <= 180)
		{
			apos[playerid] += 180;
		} else {
		    apos[playerid] -= 180;
		}
		SetPlayerAttachedObject(playerid,(index - 1),
			stats[playerid][index][model],
			stats[playerid][index][bone],
			stats[playerid][index][ox],
			stats[playerid][index][oy],
			stats[playerid][index][oz],
			stats[playerid][index][rx],
			stats[playerid][index][ry],
			stats[playerid][index][rz],
			stats[playerid][index][sx],
			stats[playerid][index][sy],
			stats[playerid][index][sz]
		);
		return 1;
	}
	ResetArray(playerid, 0);
	pindex[playerid] = index;
	DisplayIndex(playerid, index);
	frozen[playerid] = true;
	working[playerid] = true;
	camera[playerid] = false;
	TogglePlayerControllable(playerid,false);
	GetPlayerPos(playerid,ppos[playerid][0],ppos[playerid][1],ppos[playerid][2]);
	new Float:angle;
	GetPlayerFacingAngle(playerid,angle);
	apos[playerid] = floatround(angle,floatround_round);
	if(apos[playerid] <= 180)
	{
		apos[playerid] += 180;
	} else {
	    apos[playerid] -= 180;
	}
	TextDrawShowForPlayer(playerid,help);
	TextDrawShowForPlayer(playerid,legend);
	TextDrawShowForPlayer(playerid,offset);
	TextDrawShowForPlayer(playerid,edit);
	timer[playerid] = SetTimerEx("display",100,true,"i",playerid);
	SendClientMessage(playerid,COLOR,"{00FF00} You have entered the attached object editor, use {3399FF}/index{00FF00} to add an object");
	return 1;
}
CMD:scale(playerid,params[])
{
	if(!IsPlayerAdmin(playerid))
	{
	    SendClientMessage(playerid,COLOR,"Not authorized");
	    return 1;
	}
	if(!working[playerid])
	{
	    SendClientMessage(playerid,COLOR,"you need to enter the editor ( /editor )");
	    return 1;
	}
	new string[128];
	if(stats[playerid][pindex[playerid]][model] == 0)
	{
	    format(string,sizeof(string),"There is no object attached on index %d, use /index to attach one",pindex[playerid]);
	    SendClientMessage(playerid,COLOR,string);
	    return 1;
	}
	format(string,sizeof(string),"object on index %d set to original scale",pindex[playerid]);
	SendClientMessage(playerid,COLOR,string);
	stats[playerid][pindex[playerid]][sx] = 1.0;
	stats[playerid][pindex[playerid]][sy] = 1.0;
	stats[playerid][pindex[playerid]][sz] = 1.0;
	SetPlayerAttachedObject(playerid,(pindex[playerid]-1),
		stats[playerid][pindex[playerid]][model],
		stats[playerid][pindex[playerid]][bone],
		stats[playerid][pindex[playerid]][ox],
		stats[playerid][pindex[playerid]][oy],
		stats[playerid][pindex[playerid]][oz],
		stats[playerid][pindex[playerid]][rx],
		stats[playerid][pindex[playerid]][ry],
		stats[playerid][pindex[playerid]][rz],
		stats[playerid][pindex[playerid]][sx],
		stats[playerid][pindex[playerid]][sy],
		stats[playerid][pindex[playerid]][sz]
	);
	return 1;
}
	
CMD:aload(playerid,params[])
{
	if(!IsPlayerAdmin(playerid))
	{
	    SendClientMessage(playerid,COLOR,"Not authorized");
	    return 1;
	}
	if(isnull(params))
	{
	    SendClientMessage(playerid,COLOR,"USAGE: /aload [filename]");
	    if(working[playerid])
	    {
	        SendClientMessage(playerid,COLOR,"{FF6347}NOTE: {AFAFAF}this will load attachments into the editor");
	        return 1;
		}
		SendClientMessage(playerid,COLOR,"{FF6347}NOTE: {AFAFAF}this will load the attachments in roleplay mode");
		return 1;
	}
	new string[128],fstring[128];
	format(fstring,sizeof(fstring),"%s%s.ini",SAVE_PATH,params);
	if(!fexist(fstring))
	{
		format(string,sizeof(string),"%s {FF6347}not found",fstring);
		SendClientMessage(playerid,COLOR,string);
		return 1;
	}
	if(!working[playerid])
	{
		ResetArray(playerid, 0);
	}
	new part[13][10];
	new index;
	new File:oFile = fopen(fstring, io_read);
	if(oFile)
	{
	    while(fread(oFile,string))
	    {
	        explode(string,part,',');
	        index = strval(part[0]);
			SetPlayerAttachedObject(playerid,(index),
				strval(part[1]),
				strval(part[2]),
				floatstr(part[3]),
				floatstr(part[4]),
				floatstr(part[5]),
				floatstr(part[6]),
				floatstr(part[7]),
				floatstr(part[8]),
				floatstr(part[9]),
				floatstr(part[10]),
				floatstr(part[11])
			);
			if(working[playerid])
			{
			    stats[playerid][index+1][model] = strval(part[1]);
			    stats[playerid][index+1][bone] = strval(part[2]);
			    stats[playerid][index+1][ox] = floatstr(part[3]);
			    stats[playerid][index+1][oy] = floatstr(part[4]);
			    stats[playerid][index+1][oz] = floatstr(part[5]);
			    stats[playerid][index+1][rx] = floatstr(part[6]);
			    stats[playerid][index+1][ry] = floatstr(part[7]);
			    stats[playerid][index+1][rz] = floatstr(part[8]);
			    stats[playerid][index+1][sx] = floatstr(part[9]);
			    stats[playerid][index+1][sy] = floatstr(part[10]);
			    stats[playerid][index+1][sz] = floatstr(part[11]);
			}
		}
		fclose(oFile);
		format(string,sizeof(string),"%s loaded successfully",fstring);
		SendClientMessage(playerid,COLOR,string);
		return 1;
	}
	SendClientMessage(playerid,COLOR,"File error:");
	return 1;
}
CMD:asave(playerid,params[])
{
	if(!IsPlayerAdmin(playerid))
	{
	    SendClientMessage(playerid,COLOR,"Not authorized");
	    return 1;
	}
	new ref[6],string[128];
	new code = 0;
	for(new i = 1; i <= 5;i++)
	{
	    if(stats[playerid][i][model] > 0 && stats[playerid][i][bone] > 0)
	    {
	        code++;
	        ref[i] = 1;
		}
	}
	if(!code)
	{
	    SendClientMessage(playerid,COLOR,"You don't have any attachments added ( /editor )");
	    return 1;
	}
	if(isnull(params))
	{
	    format(string,sizeof(string),"USAGE: /asave [filename]  ( you have %d attached objects )",code);
	    SendClientMessage(playerid,COLOR,string);
	    return 1;
	}
	if(!ContainsValidCharacters(params))
	{
	    SendClientMessage(playerid,COLOR,"Invalid characters");
	    return 1;
	}
	format(string,sizeof(string),"%s%s.ini",SAVE_PATH,params);
	new File:oFile = fopen(string, io_write);
	if(oFile)
	{
		for(new i = 1; i <= 5; i++)
		{
		    if(stats[playerid][i][model] > 0 && stats[playerid][i][bone] > 0)
		    {
				format(string,sizeof(string),"%d,%d,%d,%.2f,%.2f,%.2f,%.1f,%.1f,%.1f,%.2f,%.2f,%.2f\n",
					(i -1),
					stats[playerid][i][model],
					stats[playerid][i][bone],
					stats[playerid][i][ox],
					stats[playerid][i][oy],
					stats[playerid][i][oz],
					stats[playerid][i][rx],
					stats[playerid][i][ry],
					stats[playerid][i][rz],
					stats[playerid][i][sx],
					stats[playerid][i][sy],
					stats[playerid][i][sz]
				);
				fwrite(oFile,string);
			}
		}
		fclose(oFile);
		format(string,sizeof(string),"%s%s.ini saved successfully",SAVE_PATH,params);
		SendClientMessage(playerid,COLOR,string);
		return 1;
	}
	SendClientMessage(playerid,COLOR,"ERROR: creating file");
	return 1;
}
CMD:camera(playerid,params[])
{
	if(!IsPlayerAdmin(playerid))
	{
	    SendClientMessage(playerid,COLOR,"Not authorized");
	    return 1;
	}
	if(!working[playerid])
	{
	    SendClientMessage(playerid,COLOR,"You are not editing attachments, /editor to enter 'edit mode'");
	    return 1;
	}
	if(!camera[playerid])
	{
	    camera[playerid] = true;
	    frozen[playerid] = false;
	    TogglePlayerControllable(playerid,true);
	    SetCameraBehindPlayer(playerid);
	    TextDrawHideForPlayer(playerid,edit);
	    TextDrawHideForPlayer(playerid,rotate);
	    TextDrawHideForPlayer(playerid,scale);
	    TextDrawHideForPlayer(playerid,offset);
	    DisplayIndex(playerid, 0);
	    return 1;
	}
	TextDrawShowForPlayer(playerid,edit);
	switch(mode[playerid])
	{
		case 0: TextDrawShowForPlayer(playerid,offset);
		case 1: TextDrawShowForPlayer(playerid,rotate);
		case 2: TextDrawShowForPlayer(playerid,scale);
	}
	DisplayIndex(playerid,pindex[playerid]);
	camera[playerid] = false;
	frozen[playerid] = true;
	TogglePlayerControllable(playerid,false);
	GetPlayerPos(playerid,ppos[playerid][0],ppos[playerid][1],ppos[playerid][2]);
	new Float:angle;
	GetPlayerFacingAngle(playerid,angle);
	apos[playerid] = floatround(angle,floatround_round);
	if(apos[playerid] <= 180)
	{
		apos[playerid] += 180;
	} else {
	    apos[playerid] -= 180;
	}
	close[playerid] = 3.0;
	return 1;
}
public display(playerid)
{
	if(!camera[playerid])
	{
		cam[playerid][0] = ppos[playerid][0] + (close[playerid] * floatsin(-apos[playerid],degrees));
		cam[playerid][1] = ppos[playerid][1] + (close[playerid] * floatcos(-apos[playerid],degrees));
		cam[playerid][2] = ppos[playerid][2] + 0.5;
		SetPlayerCameraPos(playerid,cam[playerid][0],cam[playerid][1],cam[playerid][2]);
		SetPlayerCameraLookAt(playerid,ppos[playerid][0],ppos[playerid][1],ppos[playerid][2]);
	}
	
	new keys,ud,lr;
	new mult = 1;
	GetPlayerKeys(playerid,keys,ud,lr);
	if(frozen[playerid])
	{
        if(keys & 8) mult = 10;
		if(keys & 4)
		{
		    if(ud == -128)
			{
				close[playerid] -= (0.1 * mult);
				if(close[playerid] < 0.5) close[playerid] = 8.0;
			}
		    if(ud == 128)
			{
				close[playerid] += (0.1 * mult);
				if(close[playerid] > 8.0) close[playerid] = 0.5;
			}
			if(lr == 128)
			{
			    apos[playerid] += (1 * mult);
			    if(apos[playerid] > 360) apos[playerid] = 0;
			}
			if(lr == -128)
			{
			    apos[playerid] -= (1 * mult);
			    if(apos[playerid] < 0) apos[playerid] = 360;
			}
			if(keys & 32)
			{
			    ppos[playerid][2] += (0.1 * mult);
			}
			if(keys & 1024)
			{
			    ppos[playerid][2] -= (0.1 * mult);
			}
			return 1;
		}
		if(keys & 16)
		{
			mode[playerid] = 0;
			TextDrawHideForPlayer(playerid,rotate);
			TextDrawHideForPlayer(playerid,scale);
			TextDrawShowForPlayer(playerid,offset);
		}
		if(keys & 1)
		{
			mode[playerid] = 1;
			TextDrawHideForPlayer(playerid,scale);
			TextDrawHideForPlayer(playerid,offset);
			TextDrawShowForPlayer(playerid,rotate);
		}
		if(keys & 128)
		{
			mode[playerid] = 2;
			TextDrawHideForPlayer(playerid,rotate);
			TextDrawHideForPlayer(playerid,offset);
			TextDrawShowForPlayer(playerid,scale);
		}
		if(keys & 8192)
		{
		    apos[playerid] -= (1 * mult);
		    if(apos[playerid] < 0)
		    {
		        apos[playerid] = 360;
			}
		}
		if(keys & 16384)
		{
		    apos[playerid] += (1 * mult);
		    if(apos[playerid] > 360)
		    {
		        apos[playerid] = 0;
			}
		}
		switch(mode[playerid])
		{
		    case 0:
		    {
		        if(ud == -128) stats[playerid][pindex[playerid]][oy] += (0.01 * mult);//yup
		        if(ud == 128) stats[playerid][pindex[playerid]][oy] -= (0.01 * mult);//ydown
		        if(lr == -128) stats[playerid][pindex[playerid]][oz] += (0.01 * mult);//zdown
		        if(lr == 128) stats[playerid][pindex[playerid]][oz] -= (0.01 * mult); //zup
		        if(keys & 1024) stats[playerid][pindex[playerid]][ox] -= (0.01 * mult);//xup
		        if(keys & 32) stats[playerid][pindex[playerid]][ox] += (0.01 * mult);//xdown
			}
			case 1:
		    {
		        if(ud == -128) stats[playerid][pindex[playerid]][ry] += (1.0 * mult);
		        if(ud == 128) stats[playerid][pindex[playerid]][ry] -= (1.0 * mult);
		        if(lr == -128) stats[playerid][pindex[playerid]][rz] -= (1.0 * mult);
		        if(lr == 128) stats[playerid][pindex[playerid]][rz] += (1.0 * mult);
		        if(keys & 1024) stats[playerid][pindex[playerid]][rx] -= (1.0 * mult);
		        if(keys & 32) stats[playerid][pindex[playerid]][rx] += (1.0 * mult);
			}
			case 2:
		    {
		        if(ud == -128) stats[playerid][pindex[playerid]][sy] += (0.01 * mult);
		        if(ud == 128) stats[playerid][pindex[playerid]][sy] -= (0.01 * mult);
		        if(lr == -128) stats[playerid][pindex[playerid]][sx] -= (0.01 * mult);
		        if(lr == 128) stats[playerid][pindex[playerid]][sx] += (0.01 * mult);
		        if(keys & 1024) stats[playerid][pindex[playerid]][sz] -= (0.01 * mult);
		        if(keys & 32) stats[playerid][pindex[playerid]][sz] += (0.01 * mult);
			}
		}
		if(stats[playerid][pindex[playerid]][model] > 0)
		{
			SetPlayerAttachedObject(playerid,(pindex[playerid]-1),
				stats[playerid][pindex[playerid]][model],
				stats[playerid][pindex[playerid]][bone],
				stats[playerid][pindex[playerid]][ox],
				stats[playerid][pindex[playerid]][oy],
				stats[playerid][pindex[playerid]][oz],
				stats[playerid][pindex[playerid]][rx],
				stats[playerid][pindex[playerid]][ry],
				stats[playerid][pindex[playerid]][rz],
				stats[playerid][pindex[playerid]][sx],
				stats[playerid][pindex[playerid]][sy],
				stats[playerid][pindex[playerid]][sz]
			);
		}
		
	}
	if(!camera[playerid])
	{
		if(keys & 512)
		{
			if(frozen[playerid])
			{
				TogglePlayerControllable(playerid,true);
				frozen[playerid] = false;
			    TextDrawHideForPlayer(playerid,edit);
			    TextDrawHideForPlayer(playerid,rotate);
			    TextDrawHideForPlayer(playerid,scale);
			    TextDrawHideForPlayer(playerid,offset);
			} else {
			    TogglePlayerControllable(playerid,false);
			    frozen[playerid] = true;
				switch(mode[playerid])
				{
					case 0: TextDrawShowForPlayer(playerid,offset);
					case 1: TextDrawShowForPlayer(playerid,rotate);
					case 2: TextDrawShowForPlayer(playerid,scale);
				}
				TextDrawShowForPlayer(playerid,edit);
			}
		}
	}
	return 1;
}
stock explode(string[], dest[][], token = ' ', max = sizeof (dest), ml = sizeof (dest[]))
{
	new
		len = strlen(string),
		idx,
		i,
		cur;
	while (idx < len)
	{
		if (string[idx] == token)
		{
			dest[cur][i] = '\0';
			cur++;
			if (cur == max)
			{
				return;
			}
			i = 0;
			while (idx < len && string[idx] == token)
			{
				idx++;
			}
		}
		else
		{
			dest[cur][i++] = string[idx++];
			if (i == ml)
			{
				dest[cur][--i] = '\0';
				while (idx < len && string[idx] != token)
				{
					idx++;
				}
			}
		}
	}
	dest[cur][i] = '\0';
}
public OnPlayerDisconnect(playerid, reason) // avoids issues when player disconnects while editing
{
	if(working[playerid])
	{
	    SetCameraBehindPlayer(playerid);
	    KillTimer(timer[playerid]);
	}
	working[playerid] = false;
	frozen[playerid] = false;
	camera[playerid] = false;
	ResetArray(playerid,0);
	return 1;
}
public OnPlayerConnect(playerid)
{
	SetCameraBehindPlayer(playerid);
	return 1;
}
