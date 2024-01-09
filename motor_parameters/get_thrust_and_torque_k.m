%% Get data
clc
clear all
load 22x8.mat
thrust = lbf2N(thrust_lbf);
torque = inlbf2Nm(torque_lbf);
rads = rpm2rads(rpm);

% get polynomial order 2 for thrust and torque
thrust_p = polyfit(rads,thrust,2);
torque_p = polyfit(thrust,torque,1);

thrust_p2 = thrust_p;
thrust_p2(2:3) = 0;
torque_p1 = torque_p;
torque_p1(2) = 0;


%% Plot estimated vs real
fig = 1;
figure(fig);
clf(fig);

plot(rads, thrust)
hold on
grid on
plot(rads, polyval(thrust_p, rads))
plot(rads, polyval(thrust_p2, rads))
xlabel('Angular velocity [rad/s]')
ylabel('Thrust[N]')
legend('Ground Truth', '2nd order poly', 'Only 2nd term')
%% Torque curve
fig = 2;
figure(fig);
clf(fig);

plot(thrust, torque)
hold on
grid on
plot(thrust, polyval(torque_p,thrust))
plot(thrust, polyval(torque_p1,thrust))
xlabel('Thrust [N]')
ylabel('Torque[Nm]')
legend('Ground Truth', '1st order poly', 'Only 1st term')