#include "script_component.hpp"
#define TITLE_RGBA [profilenamespace getvariable ["GUI_BCG_RGB_R",0.77],profilenamespace getvariable ["GUI_BCG_RGB_G",0.51],profilenamespace getvariable ["GUI_BCG_RGB_B",0.08],profilenamespace getvariable ["GUI_BCG_RGB_A",1]]
#define BG_RGBA [0,0,0,0.8]

[{
	params ["_logic"];

	if (isNull _logic) exitWith {};

	disableSerialization;
	if (!isNull (findDisplay 312)) then {
		if (!local _logic) exitWith {};

		if (SSS_entities isEqualTo []) exitWith {
			ZEUS_ERROR("No supports exist");
			deleteVehicle _logic;
		};

		private _object = attachedTo _logic;

		private _fnc_selectionUI = {
			disableSerialization;
			params ["_input"];

			private _requesters = if (_input isEqualType objNull) then {
				[_input]
			} else {
				(_input # 0) select {_x isKindOf "CAManBase"}
			};

			if (_requesters isEqualTo []) exitWith {
				ZEUS_ERROR("No units selected");
			};

			private _display = findDisplay 312 createDisplay "RscDisplayEmpty";

			private _title = _display ctrlCreate ["RscText",-1];
			_title ctrlSetBackgroundColor TITLE_RGBA;
			_title ctrlSetPosition [0.1,0.08,0.8,0.075];
			_title ctrlCommit 0;
			_title ctrlSetText "Select supports to be assigned";

			private _BG = _display ctrlCreate ["RscText",-1];
			_BG ctrlSetBackgroundColor BG_RGBA;
			_BG ctrlSetPosition [0.1,0.16,0.8,0.7];
			_BG ctrlCommit 0;
			_BG ctrlSetText "";

			private _cbGroup = _display ctrlCreate ["RscControlsGroup",-1];
			_cbGroup ctrlSetPosition [0.1,0.16,0.8,0.7];
			_cbGroup ctrlCommit 0;

			private _data = [];
			private _step = 0;
			private _cfgVehicles = configFile >> "CfgVehicles";

			{
				private _classDisplayName = getText (_cfgVehicles >> _x getVariable ["SSS_classname",""] >> "displayName");
				private _side = _x getVariable "SSS_side";
				private _color = switch (_side) do {
					case east : {"#800000"};
					case independent : {"#008000"};
					case west : {"#004d99"};
					case civilian : {"#b300e6"};
					default {"#ffffff"};
				};

				private _entityItem = _display ctrlCreate ["RscStructuredText",-1,_cbGroup];
				_entityItem ctrlSetBackgroundColor [0,0,0,0.1];
				_entityItem ctrlSetPosition [0.02,_step,0.7,0.05];
				_entityItem ctrlCommit 0;
				_entityItem ctrlSetStructuredText parseText format ["<t color='%1'>%2 : </t><img image='%3'/> ""%4"" - %5",_color,_side,_x getVariable "SSS_icon",_x getVariable "SSS_callsign",_classDisplayName];;

				private _checkbox = _display ctrlCreate ["RscCheckbox",-1,_cbGroup];
				_checkbox ctrlSetPosition [0.72,_step,0.04,0.048];
				_checkbox ctrlCommit 0;
				_checkbox cbSetChecked false;

				_data pushBack [_x,_checkbox];
				_step = _step + 0.06;
			} forEach ([SSS_entities select {!isNull _x},true,{str (_x getVariable "SSS_side")},{_x getVariable "SSS_callsign"}] call EFUNC(common,sortBy));

			private _cancel = _display ctrlCreate ["RscButton",-1];
			_cancel ctrlSetBackgroundColor [0,0,0,1];
			_cancel ctrlSetPosition [0.1,0.865,0.25,0.05];
			_cancel ctrlCommit 0;
			_cancel ctrlSetText "CANCEL";
			[_cancel,"ButtonClick",{_thisArgs closeDisplay 0;},_display] call CBA_fnc_addBISEventHandler;;

			private _confirm = _display ctrlCreate ["RscButton",-1];
			_confirm ctrlSetBackgroundColor [0,0,0,1];
			_confirm ctrlSetPosition [0.65,0.865,0.25,0.05];
			_confirm ctrlCommit 0;
			_confirm ctrlSetText "CONFIRM";
			[_confirm,"ButtonClick",{
				_thisArgs params ["_display","_requesters","_data"];

				private _entities = [];

				{
					if (cbChecked (_x # 1)) then {
						_entities pushBack (_x # 0)
					};
				} forEach _data;

				[_requesters,_entities] call EFUNC(common,assignRequesters);

				_display closeDisplay 0;
				ZEUS_MESSAGE("Requesters assigned");
			},[_display,_requesters,_data]] call CBA_fnc_addBISEventHandler;
		};

		if (_object isKindOf "CAManBase") then {
			_object call _fnc_selectionUI;
		} else {
			[_fnc_selectionUI] call EFUNC(common,zeusSelection);
		};

		deleteVehicle _logic;
	} else {
		if (local _logic) then {
			_logic setPos [0,0,0];
		};

		private _fnc = {
			params ["_logic"];

			if (isNull _logic) exitWith {};

			private _candidates = ([_logic getVariable ["AssignList",""],true,true] call ace_common_fnc_parseList) select {!isNil "_x" && {_x isEqualType objNull}};
			[_candidates,_logic getVariable ["SSS_entitiesToAssign",[]]] call EFUNC(common,assignRequesters);
		};

		[{
			((synchronizedObjects _this) select {_x isKindOf QGVAR(Base) && typeOf _x != QGVAR(AssignRequesters)}) isEqualTo []
		},_fnc,_logic,5,_fnc] call CBA_fnc_waitUntilAndExecute;	
	};
},_this] call CBA_fnc_directCall;
