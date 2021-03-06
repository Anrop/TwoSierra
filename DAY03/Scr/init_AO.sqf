diag_log "ADF RPT: Init - executing Scr\init_AO.sqf"; // Reporting. Do NOT edit/remove
// init
call compile preprocessFileLineNumbers "Scr\ADF_redress_Pashtun.sqf";
call compile preprocessFileLineNumbers "Core\F\ADF_fnc_vehiclePatrol.sqf";

ADF_wpPosRdm = {
	private "_wpPos";
	_wpPos = ["mAirPos_1","mAirPos_2","mAirPos_3","mAirPos_4","mAirPos_5"] call BIS_fnc_selectRandom;
	_wpPos
};

[] spawn {
	sleep 25;
	while {true} do {
		private ["_c","_v","_wp","_heli","_startPos","_exitPos","_pause"];
		_pause = [300,600,900,1200,1800] call BIS_fnc_selectRandom;
		_startPos = call ADF_wpPosRdm;
		_exitPos = call ADF_wpPosRdm;
		_heli = "sfp_hkp4_2015";
		_landPos = [oLand_1,oLand_2] call BIS_fnc_selectRandom;		
		_c = createGroup WEST;
		_v = [getMarkerPos _startPos, 0, _heli, _c] call BIS_fnc_spawnVehicle;
		_c setGroupIdGlobal ["6-1 AIRBUS"];
		vAirbus = _v select 0;
		vAirbus; [0, "Img\cusTex_NRFcamo.jpg"]; vAirbus; [1, "Img\cusTex_NRFcamo.jpg"];		
		{_x unassignItem "NVGoggles"; _x removeItem "NVGoggles"; _x enableGunlights "forceOn";} forEach units _c;
		vAirbus flyInHeight 75;
		_wp = _c addWaypoint [getPos _landPos, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointBehaviour "SAFE";
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointStatements ["true", "vAirbus land 'LAND';"];	
		waitUntil {(currentWaypoint (_wp select 0)) > (_wp select 1)};
		waitUntil {isTouchingGround vAirbus};
		{vAirbus animateDoor [_x, 1];} forEach ["door_L_source","door_R_source","Door_rear_source"];
		_pausePad = [60,120,180,240,300,600] call BIS_fnc_selectRandom;
		vAirbus setFuel 0;
		sleep _pausePad;
		vAirbus setFuel 1;
		{vAirbus animateDoor [_x, 0];} forEach ["door_L_source","door_R_source","Door_rear_source"];
		_wp = _c addWaypoint [getMarkerPos _exitPos, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointBehaviour "SAFE";
		_wp setWaypointSpeed "NORMAL";
		waitUntil {(currentWaypoint (_wp select 0)) > (_wp select 1)};
		sleep 2;
		if !(isNil "vAirbus") then {{deleteVehicle _x} forEach (crew vAirbus); deleteVehicle vAirbus; vAirbus = nil};
		sleep _pause;
	};
};

[] spawn {
	sleep random 300;
	while {alive vGunship} do {
		private ["_c","_wp","_wpPos","_pausePad"];	
		_c = createGroup WEST;
		_p = _c createUnit ["B_helipilot_F", getMarkerPos "mLMAB",[],0,"LIEUTENANT"]; _p moveInDriver vGunship;
		_p = _c createUnit ["B_helipilot_F", getMarkerPos "mLMAB",[],0,"LIEUTENANT"]; _p moveInGunner vGunship;
		_c setGroupIdGlobal ["6-6 CONDOR"];
		vGunship flyInHeight 50;
		_wpPos = call ADF_wpPosRdm;
		_wp = _c addWaypoint [getMarkerPos _wpPos, 0];
		_wp setWaypointType "MOVE"; _wp setWaypointBehaviour "SAFE"; _wp setWaypointSpeed "NORMAL";
		_wpPos = call ADF_wpPosRdm;
		_wp = _c addWaypoint [getMarkerPos _wpPos, 0]; _wp setWaypointType "MOVE";
		_wp = _c addWaypoint [getPos oGunshipPad, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointBehaviour "SAFE";
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointStatements ["true", "vGunship land 'LAND';"];		
		waitUntil {(currentWaypoint (_wp select 0)) > (_wp select 1)};
		waitUntil {isTouchingGround vGunship};
		_pausePad = [300,600,900,1200] call BIS_fnc_selectRandom;
		vGunship setFuel 0;
		if !(isNil "vGunship") then {{deleteVehicle _x} forEach (crew vGunship);};
		vGunship setDir (getDir oGunshipPad);
		sleep _pausePad;
		vGunship setFuel 1;		
	};
};

waitUntil {sleep 10; triggerActivated tStart || time > 1250};

diag_log	"-----------------------------------------------------";
diag_log "TWO SIERRA: Started spawning AO ai's";
diag_log	"-----------------------------------------------------";

// Random vehicle patrols
for "_i" from 1 to 5 do {
	private ["_spawnPos","_spawnDir","_v","_vX"];
	_spawnPos = format ["mGuerVeh_%1",_i];
	_spawnDir = markerDir _spawnPos;

	_c = createGroup INDEPENDENT;
	_v = [getMarkerPos _spawnPos, _spawnDir, "I_G_Offroad_01_armed_F", _c] call BIS_fnc_spawnVehicle;
	{[_x] call ADF_fnc_redressPashtun} forEach units _c;
	_vX = _v select 0;
	_vX setVariable ["BIS_enableRandomization", false];
	[_vX, "ADF_opforOffroad", nil] call bis_fnc_initVehicle;
	[_c, _spawnPos, 2500, 4, "MOVE", "SAFE", "RED", "LIMITED",25] call ADF_fnc_vehiclePatrol;
};

// AO Defence Fire Team
for "_i" from 1 to 12 do {
	private ["_g","_spawnPos"];
	_spawnPos = format ["mGuerPaxDef_%1",_i];
	_g = [getMarkerPos _spawnPos, INDEPENDENT, (configFile >> "CfgGroups" >> "INDEP" >> "IND_F" >> "Infantry" >> "HAF_InfTeam")] call BIS_fnc_spawnGroup;
	{[_x] call ADF_fnc_redressPashtun} forEach units _g;
	[_g, getMarkerPos _spawnPos, 75, 2, true] call CBA_fnc_taskDefend;	
};

// AO Defence Squad
for "_i" from 20 to 25 do {
	private ["_g","_spawnPos"];
	_spawnPos = format ["mGuerPaxDef_%1",_i];
	_g = [getMarkerPos _spawnPos, INDEPENDENT, (configFile >> "CfgGroups" >> "INDEP" >> "IND_F" >> "Infantry" >> "HAF_InfSquad")] call BIS_fnc_spawnGroup;
	{[_x] call ADF_fnc_redressPashtun} forEach units _g;
	[_g, getMarkerPos _spawnPos, 125, 1, true] call CBA_fnc_taskDefend;	
};

