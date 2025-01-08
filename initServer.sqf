// Configuration values
VRS_boxValue = 500;     
private _searchRadius = 200;
private _startingBudget = 0;

// Check if ACE Fortify is available
VRS_aceFortifyEnabled = isClass (configFile >> "CfgPatches" >> "ace_fortify");
if (VRS_aceFortifyEnabled) then {
    // Initialize ACE Fortify
    [west, _startingBudget, []] call ace_fortify_fnc_registerObjects;
    [east, _startingBudget, []] call ace_fortify_fnc_registerObjects;
    [independent, _startingBudget, []] call ace_fortify_fnc_registerObjects;
    [civilian, _startingBudget, []] call ace_fortify_fnc_registerObjects;
    diag_log "[VRS Info] ACE Fortify initialized";
} else {
    diag_log "[VRS Info] ACE Fortify not detected - budget system disabled";
};

// Find all boxes in play area
_centerPos = getMarkerPos "mk_boxarea";
_boxList = _centerPos nearObjects ["CargoNet_01_box_F", _searchRadius];

// Debug logging
systemChat format ["[Server] Found %1 boxes near marker", count _boxList];
diag_log format ["[VRS Debug] Server found %1 boxes at coordinates %2", count _boxList, _centerPos];

// Initialize global variables
missionNamespace setVariable ["VRS_boxList", _boxList, true];
VRS_boxSmokeMap = createHashMap;
publicVariable "VRS_boxSmokeMap";

// Handle box collection requests
["VRS_RequestBoxDelete", {
    params ["_box", "_requestingPlayer"];
    
    if (!isNull _box && {alive _box}) then {
        private _boxId = netId _box;
        deleteVehicle _box;
        ["VRS_BoxDeleted", [_boxId]] call CBA_fnc_globalEvent;
        
        // Only update budget if ACE Fortify is enabled and functions exist
        if (VRS_aceFortifyEnabled && !isNil "ace_fortify_fnc_getBudget" && !isNil "ace_fortify_fnc_setBudget") then {
            private _side = side group _requestingPlayer;
            _currentBudget = 0;
            
            // Get current budget with error handling
            try {
                _currentBudget = [_side] call ace_fortify_fnc_getBudget;
                [_side, _currentBudget + VRS_boxValue] call ace_fortify_fnc_setBudget;
                [format ["Fortify budget increased by $%1", VRS_boxValue]] remoteExec ["hint", _requestingPlayer];
            } catch {
                ["Box collected - Fortify update failed"] remoteExec ["hint", _requestingPlayer];
                diag_log "[VRS Error] ACE Fortify function call failed";
            };
        } else {
            ["Box collected"] remoteExec ["hint", _requestingPlayer];
        };
    };
}] call CBA_fnc_addEventHandler;
