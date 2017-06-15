/*
This list is used because using the environment var (and its presets) changes the sound environment
for ALL sounds, including sounds already playing. This means that if you play a sound without reverb, any
sound that is already playing will have its reverb removed. The workaround is to use the echo var. Echo
works on one sound only. However, echo does not have presets. This list stores the arguments to be passed
to echo, in order to simulate an environment preset.
*/
/datum/sound/var/list/presets=list(\
	list(7.5,   1.00,   -1000,  -100,   0,  1.49,  0.83, 1.0,  -2602, 0.007,  200,   0.011, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(1.4,   1.00,   -1000,  -6000,  0,  0.17,  0.10, 1.0,  -1204, 0.001,  207,   0.002, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(1.9,   1.00,   -1000,  -454,   0,  0.40,  0.83, 1.0,  -1646, 0.002,  53,    0.003, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(1.4,   1.00,   -1000,  -1200,  0,  1.49,  0.54, 1.0,  -370,  0.007,  1030,  0.011, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(2.5,   1.00,   -1000,  -6000,  0,  0.50,  0.10, 1.0,  -1376, 0.003,  -1104, 0.004, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(11.6,  1.00,   -1000,  -300,   0,  2.31,  0.64, 1.0,  -711,  0.012,  83,    0.017, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(21.6,  1.00,   -1000,  -476,   0,  4.32,  0.59, 1.0,  -789,  0.020,  -289,  0.030, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(19.6,  1.00,   -1000,  -500,   0,  3.92,  0.70, 1.0,  -1230, 0.020,  -2,    0.029, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(14.6,  1.00,   -1000,  0,      0,  2.91,  1.30, 1.0,  -602,  0.015,  -302,  0.022, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(36.2,  1.00,   -1000,  -698,   0,  7.24,  0.33, 1.0,  -1166, 0.020,  16,    0.030, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(50.3,  1.00,   -1000,  -1000,  0,  10.05, 0.23, 1.0,  -602,  0.020,  198,   0.030, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(1.9,   1.00,   -1000,  -4000,  0,  0.30,  0.10, 1.0,  -1831, 0.002,  -1630, 0.030, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(1.8,   1.00,   -1000,  -300,   0,  1.49,  0.59, 1.0,  -1219, 0.007,  441,   0.011, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(13.5,  1.00,   -1000,  -237,   0,  2.70,  0.79, 1.0,  -1214, 0.013,  395,   0.020, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(7.5,   0.30,   -1000,  -270,   0,  1.49,  0.86, 1.0,  -1204, 0.007,  -4,    0.011, 0.125,  0.95,  0.25, 0.000, -5.0,  5000.0),
	list(38.0,  0.30,   -1000,  -3300,  0,  1.49,  0.54, 1.0,  -2560, 0.162,  -229,  0.088, 0.125,  1.00,  0.25, 0.000, -5.0,  5000.0),
	list(7.5,   0.50,   -1000,  -800,   0,  1.49,  0.67, 1.0,  -2273, 0.007,  -1691, 0.011, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(100.0, 0.27,   -1000,  -2500,  0,  1.49,  0.21, 1.0,  -2780, 0.300,  -1434, 0.100, 0.250,  1.00,  0.25, 0.000, -5.0,  5000.0),
	list(17.5,  1.00,   -1000,  -1000,  0,  1.49,  0.83, 1.0,  -10000,0.061,  500,   0.025, 0.125,  0.70,  0.25, 0.000, -5.0,  5000.0),
	list(42.5,  0.21,   -1000,  -2000,  0,  1.49,  0.50, 1.0,  -2466, 0.179,  -1926, 0.100, 0.250,  1.00,  0.25, 0.000, -5.0,  5000.0),
	list(8.3,   1.00,   -1000,  0,      0,  1.65,  1.50, 1.0,  -1363, 0.008,  -1153, 0.012, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(1.7,   0.80,   -1000,  -1000,  0,  2.81,  0.14, 1.0,  429,   0.014,  1023,  0.021, 0.250,  0.00,  0.25, 0.000, -5.0,  5000.0),
	list(1.8,   1.00,   -1000,  -4000,  0,  1.49,  0.10, 1.0,  -449,  0.007,  1700,  0.011, 0.250,  0.00,  1.18, 0.348, -5.0,  5000.0),
	list(1.9,   0.50,   -1000,  0,      0,  8.39,  1.39, 1.0,  -115,  0.002,  985,   0.030, 0.250,  0.00,  0.25, 1.000, -5.0,  5000.0),
	list(1.8,   0.60,   -1000,  -400,   0,  17.23, 0.56, 1.0,  -1713, 0.020,  -613,  0.030, 0.250,  1.00,  0.81, 0.310, -5.0,  5000.0),
	list(1.0,   0.50,   -1000,  -151,   0,  7.56,  0.91, 1.0,  -626,  0.020,  774,   0.030, 0.250,  0.00,  4.00, 1.000, -5.0,  5000.0))

/*
Sound evironments are presets that control the reverb of a sound, modeled off actual environments.
Our sound system's default environment is 0, or 'generic', which is a simple reverb model. You should probably
set this to something different. You can set a sound environment by assigning an area a `sound_environment` var.
The following list contains all of the sound environments:

0	generic
1	padded cell
2	room
3	bathroom
4	livingroom
5	stoneroom
6	auditorium
7	concert hall
8	cave
9	arena
10	hangar
11	carpetted hallway
12	hallway
13	stone corridor
14	alley
15	forest
16	city
17	mountains
18	quarry
19	plain
20	parking lot
21	sewer pipe
22	underwater
23	drugged
24	dizzy
25	psychotic

For information on how to further customize reverb, view http://www.byond.com/docs/ref/info.html#/sound/var/echo
*/
