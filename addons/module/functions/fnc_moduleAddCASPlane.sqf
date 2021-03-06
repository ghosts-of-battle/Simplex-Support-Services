#include "script_component.hpp"

[{
	params ["_logic"];

	disableSerialization;
	if (!isNull (findDisplay 312)) then {
		if (!local _logic) exitWith {};

		private _object = attachedTo _logic;
		private _classname = "B_Plane_CAS_01_F";
		private _callsign = "";
		private _weaponSet = str ["Gatling_30mm_Plane_CAS_01_F","Rocket_04_HE_Plane_CAS_01_F","Bomb_04_Plane_CAS_01_F"];

		if (_object isKindOf "Plane") then {
			_classname = typeOf _object;
			_callsign = getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayName");
			_weaponSet = str ((weapons _object) select {
				toLower ((_x call BIS_fnc_itemType) # 1) in ["machinegun","rocketlauncher","missilelauncher","bomblauncher"]
			});
		};

		["Add CAS Plane",[
			["EDITBOX","Classname",_classname],
			["EDITBOX","Callsign",_callsign],
			["EDITBOX",["Weapon set","Array of weapon classnames or array of [weapon,magazine] arrays. Empty array for vehicle defaults"],_weaponSet],
			["COMBOBOX","Side",[["BLUFOR","OPFOR","Independent"],0]],
			["EDITBOX","Cooldown",str DEFAULT_COOLDOWN_PLANES],
			["EDITBOX",["Custom init code","Code executed when physical vehicle is spawned (vehicle = _this)"],""]
		],{
			params ["_values"];
			_values params ["_classname","_callsign","_weaponSet","_sideSelection","_cooldown"];

			[
				[],
				_classname,
				_callsign,
				parseSimpleArray _weaponSet,
				[west,east,independent] # _sideSelection,
				parseNumber _cooldown
			] call EFUNC(support,addCASPlane);

			ZEUS_MESSAGE("CAS Plane added");
		}] call EFUNC(CDS,dialog);
	} else {
		if (!isServer) exitWith {};

		private _requesterModules = [];
		private _requesters = [];

		{
			if (typeOf _x == QGVAR(AssignRequesters)) then {
				_requesterModules pushBack _x;
				_requesters append ((synchronizedObjects _x) select {!(_x isKindOf "Logic")});
			};
		} forEach synchronizedObjects _logic;

		private _entity = [
			_requesters,
			_logic getVariable ["Classname",""],
			_logic getVariable ["Callsign",""],
			parseSimpleArray (_logic getVariable ["WeaponSet","[]"]),
			[west,east,independent] # (_logic getVariable ["Side",0]),
			parseNumber (_logic getVariable ["Cooldown",str DEFAULT_COOLDOWN_PLANES]),
			_logic getVariable ["CustomInit",""]
		] call EFUNC(support,addCASPlane);

		{_x setVariable ["SSS_entitiesToAssign",(_x getVariable ["SSS_entitiesToAssign",[]]) + [_entity],true]} forEach _requesterModules;
	};

	deleteVehicle _logic;
},_this] call CBA_fnc_directCall;
