// Define smoke colors
private _smokeColors = [
    [[0, 0.3, 1]], // Blue
    [[1, 0.3, 0]], // Red
    [[0, 1, 0.3]], // Green
    [[0.7, 0, 1]], // Purple
    [[1, 0.8, 0]]  // Yellow
];

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
