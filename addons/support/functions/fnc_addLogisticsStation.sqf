#include "script_component.hpp"

params [
	["_requesters",[],[[]]],
	["_spawnPosASL",[],[[],objNull]],
	["_spawnDir",0,[0]],
	["_callsign","",[""]],
	["_listFnc",{},["",{}]],
	["_universalInitFnc",{},["",{}]],
	["_side",sideEmpty,[sideEmpty]]
];

// Validation
if (_spawnPosASL isEqualType objNull) then {
	_spawnPosASL = getPosASL _spawnPosASL;
};

_spawnPosASL params [["_posX",0,[0]],["_posY",0,[0]],["_posZ",0,[0]]];
_spawnPosASL = [_posX,_posY,_posZ];

if (_callsign isEqualTo "") then {
	_callsign = "Logistics Station";
};

if (_listFnc isEqualType "") then {
	_listFnc = compile _listFnc;
};

if (_universalInitFnc isEqualType "") then {
	_universalInitFnc = compile _universalInitFnc;
};

if (!isServer) exitWith {
	_this remoteExecCall [QFUNC(addLogisticsStation),2];
	objNull
};

// Basic setup
private _entity = true call CBA_fnc_createNamespace;

BASE_TRAITS(_entity,nil,_callsign,_side,ICON_BOX,{},"logistics","logisticsStation");

// Specifics
_entity setVariable ["SSS_spawnPointASL",_spawnPosASL,true];
_entity setVariable ["SSS_spawnDir",_spawnDir,true];
_entity setVariable ["SSS_listFnc",_listFnc,true];
_entity setVariable ["SSS_universalInitFnc",_universalInitFnc,true];

// Assignment
[_requesters,[_entity]] call EFUNC(common,assignRequesters);
SSS_entities pushBack _entity;
publicVariable "SSS_entities";

// Event handlers
[_entity,"Deleted",{_this call EFUNC(common,deletedEntity)}] call CBA_fnc_addBISEventHandler;

_entity
