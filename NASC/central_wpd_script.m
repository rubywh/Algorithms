

%%%centralwpd script%%%


p1_1 = '1_arms_swinging.csv';
p1_2 = '1_hands_pockets.csv';
p1_lb = '1_leg_bash_accelerometer.csv';

p2_1 = '2_arms_swinging.csv';
p2_2 = '2_hands_in_pockets.csv';

p3_1 = '3_arms_swinging.csv';
p3_2 = '3_hands_in_pockets.csv';
p3_3 = '3_arms_swinging_change.csv';
p3_4 = '3_hands_in_pockets_change_accelerometer.csv';

p4_1 = '4_arms_swinging.csv';
p4_2 = '4_hands_pockets.csv';
p4_3 = '4_arms_swinging_change_accelerometer.csv';
p4_4 = '4_hands_pockets_change_accelerometer.csv';


p5_1 = '5_arms_swinging.csv';
p5_2 = '5_hands_pockets.csv';
p5_3 = '5_arms_swinging_change.csv';
p5_4 = '5_hands_pockets_change.csv';


p6_1 = '6_arms_swinging.csv';
p6_2 = '6_hands_pockets.csv';
p6_3 = '6_arms_swinging_change_accelerometer.csv';
p6_4 = '6_hands_pockets_change_accelerometer.csv';

p7_1 = '7_arms_swinging.csv';
p7_2 = '7_hands_in_pockets.csv';
p7_3 = '7_arms_swinging_change.csv';
p7_4 = '7_hands_pockets_change_accelerometer.csv';




p1_1s = 6400000000;
p1_1e = 58600000000;
p1_lbs = 1800000000;
p1_lbe=52400000000;

p1_2s = 3900000000;
p1_2e = 54800000000;

p2_1s = 7100000000;
p2_1e = 59100000000;
p2_2s = 1400000000;
p2_2e = 55200000000;

p3_1s = 5000000000;
p3_1e = 76500000000;
p3_2s = 1440000000;
p3_2e = 60750000000;
p3_3s = 4700000000;
p3_3e = 66900000000;
p3_4s = 3900000000;
p3_4e = 64300000000;


p4_1s = 1350000000;
p4_1e = 59500000000;
p4_2s = 6600000000;
p4_2e = 64900000000;
p4_3s = 5400000000;
p4_3e = 58300000000;
p4_4s = 5500000000;
p4_4e = 60500000000;


p5_1s = 2100000000;
p5_1e = 60800000000;
p5_2s = 3600000000;
p5_2e = 58900000000;
p5_3s = 1100000000;
p5_3e = 52300000000;
p5_4s = 3200000000;
p5_4e = 53700000000;

p6_1s = 4000000000;
p6_1e = 54300000000;
p6_2s = 2900000000;
p6_2e = 52500000000;
p6_3s = 1300000000;
p6_3e = 47000000000;
p6_4s = 1600000000;
p6_4e = 53900000000;

p7_1s = 1500000000;
p7_1e = 53300000000;
p7_2s = 1700000000;
p7_2e = 52300000000;
p7_3s = 1200000000;
p7_3e = 48600000000;
p7_4s = 1450000000;
p7_4e = 47800000000;


%[p1(1,1), p1(1,2)] = bfs_wpd(p1_1, p1_1s, p1_1e, 100, 0, 557200000);
%[p1(2,1), p1(2,2)] = bfs_wpd(p1_2, p1_2s, p1_2e, 100, 0, 557200000);
%[p1(5,1), p1(5,2)] = bfs_wpd(p1_lb, p1_lbs, p1_lbe, 110,0, 557200000);

%[p2(1,1), p2(1,2)] = bfs_wpd(p2_1, p2_1s, p2_1e, 100, 0, 557200000);
%[p2(2,1), p2(2,2)] = bfs_wpd(p2_2, p2_2s, p2_2e, 100, 0, 557200000);

%[p3(1,1), p3(1,2)] = bfs_wpd(p3_1, p3_1s, p3_1e, 100, 0, 557200000);
%[p3(2,1), p3(2,2)] = bfs_wpd(p3_2, p3_2s, p3_2e, 100,0, 557200000);
%[p3(3,1), p3(3,2)] = bfs_wpd(p3_3, p3_3s, p3_3e, 90,0, 557200000);
%[p3(4,1), p3(4,2)] = bfs_wpd(p3_4, p3_4s, p3_4e, 90,0, 557200000);


%[p4(1,1), p4(1,2)] = bfs_wpd(p4_1, p4_1s, p4_1e, 100,0, 557200000);
%[p4(2,1), p4(2,2)] = bfs_wpd(p4_2, p4_2s, p4_2e, 100,0, 557200000);
%[p4(3,1), p4(3,2)] = bfs_wpd(p4_3, p4_3s, p4_3e, 90,0, 557200000);
%[p4(4,1), p4(4,2)] = bfs_wpd(p4_4, p4_4s, p4_4e, 90,0, 557200000);



[p5(1,1), p5(1,2)] = bfs_wpd(p5_1, p5_1s, p5_1e, 102,1, 552800000);
%[p5(2,1), p5(2,2)] = bfs_wpd(p5_2, p5_2s, p5_2e, 100,0, 552800000);
%[p5(3,1), p5(3,2)] = bfs_wpd(p5_3, p5_3s, p5_3e, 90,0, 552800000);
%[p5(4,1), p5(4,2)] = bfs_wpd(p5_4, p5_4s, p5_4e, 90,0, 552800000);

%[p6(1,1), p6(1,2)] = bfs_wpd(p6_1, p6_1s, p6_1e, 100,0, 557200000);
%[p6(2,1), p6(2,2)] = bfs_wpd(p6_2, p6_2s, p6_2e, 100,0, 557200000);
%[p6(3,1), p6(3,2)] = bfs_wpd(p6_3, p6_3s, p6_3e, 90,0, 557200000);
%[p6(4,1), p6(4,2)] = bfs_wpd(p6_4, p6_4s, p6_4e, 90,0, 557200000);

%[p7(1,1), p7(1,2)] = bfs_wpd(p7_1, p7_1s, p7_1e, 100,0, 590000000);
%[p7(2,1), p7(2,2)] = bfs_wpd(p7_2, p7_2s, p7_2e, 100,0, 590000000);
%[p7(3,1), p7(3,2)] = bfs_wpd(p7_3, p7_3s, p7_3e, 90,0, 590000000);
%[p7(4,1), p7(4,2)] = bfs_wpd(p7_4, p7_4s, p7_4e, 90,0, 590000000);

  