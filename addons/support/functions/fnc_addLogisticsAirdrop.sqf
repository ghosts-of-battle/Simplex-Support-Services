#include "script_component.hpp"

params [
	["_requesters",[],[[]]],
	["_classname","",[""]],
	["_callsign","",[""]],
	["_spawnPosition",[],[[]]],
	["_spawnDelay",DEFAULT_LOGISTICS_AIRDROP_SPAWN_DELAY,[0]],
	["_flyingHeight",DEFAULT_LOGISTICS_AIRDROP_FLYING_HEIGHT,[0]],
	["_listFnc","",["",{}]],
	["_universalInitFnc",{},["",{}]],
	["_allowMulti",false,[false]],
	["_side",sideEmpty,[sideEmpty]],
	["_cooldownDefault",DEFAULT_COOLDOWN_LOGISTICS_AIRDROP,[0]],
	["_customInit","",["",{}]]
];

// Validation
if (_classname isEqualTo "" || !(_classname isKindOf "Air")) exitWith {
	SSS_ERROR_1("Invalid Logistics Airdrop classname: %1",_classname);
	objNull
};

if (_callsign isEqualTo "") then {
	_callsign = "Logistics Airdrop";
};

if !(_spawnPosition isEqualTo []) then {
	_spawnPosition params [["_posX",0,[0]],["_posY",0,[0]]];
	_spawnPosition = [_posX,_posY,_flyingHeight];
};

if (_listFnc isEqualType "") then {
	_listFnc = compile _listFnc;
};

if (_universalInitFnc isEqualType "") then {
	_universalInitFnc = compile _universalInitFnc;
};

if (_customInit isEqualType "") then {
	_customInit = compile _customInit;
};

if (!isServer) exitWith {
	_this remoteExecCall [QFUNC(addLogisticsAirdrop),2];
	objNull
};

// Basic setup
private _entity = true call CBA_fnc_createNamespace;

BASE_TRAITS(_entity,_classname,_callsign,_side,ICON_PARACHUTE,_customInit,"logistics","logisticsAirdrop");
CREATE_TASK_MARKER(_entity,_callsign,"mil_end","Airdrop");

// Specifics
_entity setVariable ["SSS_spawnPosition",_spawnPosition,true];
_entity setVariable ["SSS_spawnDelay",_spawnDelay,true];
_entity setVariable ["SSS_flyingHeight",_flyingHeight,true];
_entity setVariable ["SSS_listFnc",_listFnc,true];
_entity setVariable ["SSS_universalInitFnc",_universalInitFnc,true];
_entity setVariable ["SSS_allowMulti",_allowMulti,true];
_entity setVariable ["SSS_cooldown",0,true];
_entity setVariable ["SSS_cooldownDefault",_cooldownDefault,true];

// Assignment
[_requesters,[_entity]] call EFUNC(common,assignRequesters);
SSS_entities pushBack _entity;
publicVariable "SSS_entities";

// Event handlers
[_entity,"Deleted",{_this call EFUNC(common,deletedEntity)}] call CBA_fnc_addBISEventHandler;

_entity
