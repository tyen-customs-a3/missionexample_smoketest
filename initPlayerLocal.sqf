// Get box list from server
private _boxList = missionNamespace getVariable "VRS_boxList";

// Debug info
systemChat format ["[Client] Initializing %1 boxes", count _boxList];
diag_log format ["[VRS Debug] Client initializing %1 boxes", count _boxList];

// Process each box
{
    private _box = _x;
    private _smoke = "#particlesource" createVehicleLocal position _box;
    
    // Enhanced smoke configuration for natural fade
    _smoke setParticleParams [
        ["\A3\data_f\cl_basic", 1, 0, 1],      // Shape
        "",                                      // Animation
        "Billboard",                            // Type
        1,                                      // Timer
        6,                                      // Lifetime (increased)
        [0, 0, 0],                             // Position
        [0, 0, 0.8],                           // Move velocity (increased)
        0.5,                                    // Rotation velocity (reduced)
        0.05,                                   // Weight
        0.042,                                  // Volume
        0.04,                                   // Rubbing (reduced)
        [0.3, 1.5, 3],                         // Size (gradual increase)
        [
            [0, 0.3, 1, 0],                    // Start transparent
            [0, 0.3, 1, 0.4],                  // Fade in
            [0, 0.3, 1, 0.3],                  // Peak
            [0, 0.3, 1, 0.2],                  // Start fade
            [0, 0.3, 1, 0.1],                  // More fade
            [0, 0.3, 1, 0]                     // End transparent
        ],
        [0.08],                                 // Animation (slower)
        1,                                      // Random dir period
        0.1,                                    // Random dir intensity
        "",                                     // On timer script
        "",                                     // Before destroy script
        _box                                    // Object to follow
    ];
    
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
        "{cursorObject isEqualTo _target}",
        "true",
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
