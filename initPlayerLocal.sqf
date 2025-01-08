// Define smoke colors - Add this at the top of the file
private _smokeColors = [
    [[0, 0.3, 1]], // Blue-ish
    [[1, 0.3, 0]], // Red-ish
    [[0, 1, 0.3]], // Green-ish
    [[0.7, 0, 1]], // Purple-ish
    [[1, 0.8, 0]]  // Yellow-ish
];

// Add the function to create smoke parameters
private _fnc_getSmokeParams = {
    params ["_box"];
    private _selectedColor = selectRandom _smokeColors;
    
    [
        ["\A3\data_f\cl_basic", 1, 0, 1],
        "",
        "Billboard",
        1,
        6,
        [0, 0, 0],
        [0, 0, 0.8],
        0.5,
        0.05,
        0.042,
        0.04,
        [0.3, 1.5, 3],
        [
            [(_selectedColor # 0) # 0, (_selectedColor # 0) # 1, (_selectedColor # 0) # 2, 0],
            [(_selectedColor # 0) # 0, (_selectedColor # 0) # 1, (_selectedColor # 0) # 2, 0.4],
            [(_selectedColor # 0) # 0, (_selectedColor # 0) # 1, (_selectedColor # 0) # 2, 0.3],
            [(_selectedColor # 0) # 0, (_selectedColor # 0) # 1, (_selectedColor # 0) # 2, 0.2],
            [(_selectedColor # 0) # 0, (_selectedColor # 0) # 1, (_selectedColor # 0) # 2, 0.1],
            [(_selectedColor # 0) # 0, (_selectedColor # 0) # 1, (_selectedColor # 0) # 2, 0]
        ],
        [0.08],
        1,
        0.1,
        "",
        "",
        _box
    ]
};

// Get box list from server
private _boxList = missionNamespace getVariable "VRS_boxList";

// Debug info
systemChat format ["[Client] Initializing %1 boxes", count _boxList];
diag_log format ["[VRS Debug] Client initializing %1 boxes", count _boxList];

// Process each box
{
    private _box = _x;
    private _smoke = "#particlesource" createVehicleLocal position _box;
    
    // Enhanced smoke configuration using function
    _smoke setParticleParams ([_box] call _fnc_getSmokeParams);
    
    _smoke setParticleRandom [
        3,                                      // Life time
        [0.5, 0.5, 0.2],                       // Position
        [0.2, 0.2, 0.4],                       // Move velocity
        0.4,                                    // Rotation velocity
        0.2,                                    // Size
        [0, 0, 0, 0.1],                        // Color
        0.2,                                    // Random direction period
        0.1                                     // Random direction intensity
    ];

    _smoke setDropInterval 0.15;                // Slower emission rate
    
    // Track smoke effect
    private _boxId = netId _box;
    VRS_boxSmokeMap set [_boxId, _smoke];
    
    // Debug logging
    systemChat format ["[Client] Created smoke for box at %1", position _box];
    diag_log format ["[VRS Debug] Created smoke for box ID %1 at pos %2", _boxId, position _box];
    
    // Add interaction with proper visibility
    [
        _box,
        "Collect Box",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
        "cursorObject isEqualTo _target && {_this distance _target < 5}", // Condition to show
        "true", // Condition to hide
        {},
        {},
        {
            params ["_target", "_caller"];
            ["VRS_RequestBoxDelete", [_target, _caller]] call CBA_fnc_serverEvent;
        },
        {},
        [],
        2,     // Duration
        10,    // Distance
        true,  // Hide on use
        false, // Don't show in unconscious state
        true,  // Show in 3D
        true   // Hide in scroll menu (added parameter)
    ] call BIS_fnc_holdActionAdd;  // Local execution, no remoteExec needed
    
} forEach _boxList;

// Cleanup handler
["VRS_BoxDeleted", {
    params ["_boxId"];
    private _smoke = VRS_boxSmokeMap get _boxId;
    if (!isNil "_smoke") then {
        deleteVehicle _smoke;
        VRS_boxSmokeMap deleteAt _boxId;
    };
}] call CBA_fnc_addEventHandler;
