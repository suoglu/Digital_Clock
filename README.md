# Digital Clock

### Contents of Readme

1. About
2. Simulation

[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-6C488A.svg)](https://gitlab.com/suoglu/digitalClock)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-3D76C2.svg)](https://github.com/suoglu/Digital_Clock)

---

### About

This project is a digital clock with date function. It is still under development.

* [`clockwork.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/clockwork.v): Hours, Minutes and Seconds  
* [`date_module.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/date_module.v): Days, Months and Years
* [`alarm.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/alarm.v): Alarm with enable control

---

### Simulation

* [`testbench.v`](https://github.com/suoglu/Digital_Clock/blob/master/Sim/testbench.v) is used to simulate [`clockwork.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/clockwork.v) and [`date_module.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/date_module.v)
* [`testbench_alarm.v`](https://github.com/suoglu/Digital_Clock/blob/master/Sim/testbench_alarm.v) is used to simulate [`alarm.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/alarm.v)

**Last simulation date:**

* [`clockwork.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/clockwork.v): 5 April 2020 with Icarus Verilog  
* [`date_module.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/date_module.v): 8 April 2020 with Icarus Verilog
* [`alarm.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/alarm.v): 28 April 2020 with Icarus Verilog
