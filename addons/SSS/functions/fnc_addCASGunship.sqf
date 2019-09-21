#include "script_component.hpp"

params [
	["_requesters",[],[[]]],
	["_callSign","",[""]],
	["_side",sideEmpty,[sideEmpty]],
	["_cooldownDefault",SSS_DEFAULT_COOLDOWN_GUNSHIPS,[0]],
	["_loiterTime",SSS_DEFAULT_LOITER_TIME_GUNSHIPS,[0]]
];

private _classname = "B_T_VTOL_01_armed_F";

// Validation
if (_callsign isEqualTo "") then {
	_callsign = getText (configFile >> "CfgVehicles" >> _classname >> "displayName");
};

if (!isServer) exitWith {
	_this remoteExecCall [QFUNC(addCASGunship),2];
	nil
};

// Basic setup
private _entity = (createGroup sideLogic) createUnit ["Logic",[-69,-69,0],[],0,"CAN_COLLIDE"];

BASE_TRAITS(_entity,_classname,_callsign,_side,ICON_GUNSHIP,ICON_GUNSHIP_YELLOW,ICON_GUNSHIP_GREEN,"CAS","CASGunship");
CREATE_TASK_MARKER(_entity,_callsign,"mil_end","CAS");

// Specifics
_entity setVariable ["SSS_cooldown",0,true];
_entity setVariable ["SSS_cooldownDefault",_cooldownDefault,true];
_entity setVariable ["SSS_loiterTime",_loiterTime,true];
_entity setVariable ["SSS_active",false,true];

// Assignment
[_requesters,[_entity]] call FUNC(assignRequesters);
SSS_entities pushBack _entity;
publicVariable "SSS_entities";

[_entity,"Deleted",{_this call FUNC(deletedEntity)}] call CBA_fnc_addBISEventHandler;

_entity
