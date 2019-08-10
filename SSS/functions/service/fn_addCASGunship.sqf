#include "script_component.hpp"

params [
	["_callSign","",[""]],
	["_side",sideEmpty,[sideEmpty]],
	["_cooldownDefault",SSS_setting_CASGunshipsCooldownDefault,[0]],
	["_loiterTime",SSS_setting_CASGunshipsLoiterTime,[0]]
];

if (!isServer) exitWith {_this remoteExecCall ["SSS_fnc_addCASGunship",2];};

// Validation
private _classname = "B_T_VTOL_01_armed_F";
if (_callsign isEqualTo "") then {_callsign = getText (configFile >> "CfgVehicles" >> _classname >> "displayName");};
if (_side isEqualTo sideEmpty) exitWith {SSS_ERROR_1("No side defined for %1 (%2)",_callsign,_classname)};

// Basic setup
private _entity = (createGroup sideLogic) createUnit ["logic",[0,0,0],[],0,"CAN_COLLIDE"];
SET_VEHICLE_TRAITS(_entity,_classname,_side,"CASGunships",_callsign)
CREATE_TASK_MARKER(_entity,"mil_end","CAS",_callsign)

// Support specific setup
_entity setVariable ["SSS_cooldown",0,true];
_entity setVariable ["SSS_cooldownDefault",_cooldownDefault,true];
_entity setVariable ["SSS_loiterTime",_loiterTime,true];
_entity setVariable ["SSS_activeInArea",false,true];

// Assignment
ADD_SUPPORT_VEHICLE(_entity,_side,"CASGunships")

// CBA Event
private _JIPID = ["SSS_supportEntityAdded",_entity] call CBA_fnc_globalEventJIP;
[_JIPID,_entity] call CBA_fnc_removeGlobalEventJIP;