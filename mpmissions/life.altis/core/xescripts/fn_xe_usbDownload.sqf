private["_player","_npc","_ui","_progress","_pgText","_barProgress","_rip","_pos"];
_npc = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;
_player = [_this,1,ObjNull,[ObjNull]] call BIS_fnc_param;
_actionID = [_this,2] call BIS_fnc_param;

_distance = 5;
_minMoney = 200000;
_maxMoney = 300000;
_copsRequire = 4;
_speedProgressBar = 0.004;
_timeToReset = 3600;

_rip = false;
_cops = (west countSide playableUnits);

if(_player distance _npc > _distance) exitWith { hint "Devi stare entro "+str(_distance)+"m"};
if(_rip) exitWith { hint localize"STR_usbAction_alreadyInDownloading" };
if(vehicle player != _player) exitWith { hint localize"STR_usbAction_noVeh" };
if!(alive _player) exitWith {};
// if(currentWeapon _player == "") exitWith { hint localize"STR_usbAction_needUSB" }; // serve l'usb
if(_cops < _copsRequire) exitWith {
	[_vault,-1] remoteExec ["disableSerialization;",2];
	hint "Servono "+str(_copsRequire)+" agenti in servizio";
};
disableSerialization;

_rip = true;
_npc removeAction _actionID;
[false,"usb",1] call life_fnc_handleInv;

[1,format[localize"STR_usbAction_alarm", _npc]] remoteExec ["life_fnc_broadcast",west];

5 cutRsc ["life_progress","PLAIN"];
_ui = uiNameSpace getVariable "life_progress";
_progress = _ui displayCtrl 38201;
_pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["Download avviato, resta vicino ("+str(_distance)+"m) (1%1)...","%"];
_progress progressSetPosition 0.01;
_barProgress = 0.0001;

if(_rip) then {
	while{true} do {
		sleep 2;
		_barProgress = _barProgress + _speedProgressBar;
		_progress progressSetPosition _barProgress;
		_pgText ctrlSetText format["Download avviato, resta vicino ("+str(_distance)+"m) (%1%2)...",round(_barProgress * 100),"%"];

		if(_barProgress >= 1) exitWith {};
		if(_player distance _npc > _distance) exitWith {};
		if!(alive _player) exitWith {};
	};
	if!(alive _player) exitWith { _rip = false; };
	if(_player distance _npc > _distance) exitWith { 
		hint localize"STR_usbAction_tooFar"; 
		5 cutText ["","PLAIN"];
		_rip = false;
	};
	5 cutText ["","PLAIN"];

	titleText[format[localize"STR_usbAction_downloaded"],"PLAIN"];
	[true,"dati",1] call life_fnc_handleInv;

	_rip = false;
	if!(alive _player) exitWith {};
	[getPlayerUID _player,name _player,"211"] remoteExec ["life_fnc_wantedAdd",2];
};

sleep _timeToReset;
_actionID = _npc addAction[localize"STR_usbAction_downloadFiles",life_fnc_xe_usbDownload];