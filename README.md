# Digital Clock

## Contents of Readme

1. About
2. System Description
    1. Clockwork
    2. Date module
    3. Alarm module
3. Port Descriptions
    1. Clockwork
    2. Date module
    3. Alarm module
4. Simulation
5. Test
6. Status

[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-6C488A.svg)](https://gitlab.com/suoglu/digitalClock)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-3D76C2.svg)](https://github.com/suoglu/Digital_Clock)

---

## About

This project is a digital clock with date function. Currently works with 24h time format. It is still under development.

## System Description

Functionalities are seperated into different files, follows as:

- [`clockwork.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/clockwork.v): Hours, Minutes and Seconds  
- [`date_module.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/date_module.v): Days, Months and Years
- [`alarm.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/alarm.v): Alarm with an enable control

**`clockWork`:**

This module provides basic time functionality. It uses a 1 Hz clock. This module does not provide a seperate reset signal, thus resetting should be done via time overwrite signal, `time_ow`.

Time is kept in 17 bits. Most significant 5 bits represent hour, following 6 bits represent minute and 6 least significant bits represent seconds.

**`date_module`:**

This module provides an "add-on" to provide date functionality. It uses current hour to keep track of date. Similar to `clockWork` module, resetting should be done via date overwrite signal, `date_ow`.

Date is kept in 9 + year bits. Year bits determined via parameter `YEARRES`. Most significant 5 bits represent day, following 4 bits represent month and remaining bits represent year. Default value for `YEARRES` is 12 bits.

**`alarm`:**

This module provides an "add-on" alarm. Alarm can be enabled via `en_in`. Signal `ring` is set when alarm is ring. And it is kept high until `end_ring` is set.

Alarm is not sensitive to the seconds.

## Port Descriptions

**`clockWork`:**

|   Port   |  Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
| `clk_1hz` |  I  | 1 | 1 Hz Clock |
| `time_in` |  I  | 17 | Time input |
| `time_out` |  O  | 17 | Time output |
| `time_ow` |  I  | 1 | Time overwrite |

**`date_module`:**

|   Port   |  Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
| `clk` |  I  | 1 | System Clock |
| `hour_in` |  I  | 5 | Current hour |
| `date_in` |  I  | `YEARRES`+9 | Date input |
| `date_out` |  O  | `YEARRES`+9 | Date output |
| `date_ow` |  I  | 1 | Date overwrite |

`YEARRES` parameter determines the size of year register, default is 12 bits.

**`alarm`:**

|   Port   |  Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
| `clk` |  I  | 1 | System Clock |
| `rst` |  I  | 1 | System Reset |
| `en_in` |  I  | 1 | Enable Alarm |
| `time_in` |  I  | 11 | Time input (No seconds) |
| `time_set_in` |  I  | 11 | Time setting input (No seconds) |
| `set_time` |  I  | 1 | Set Alarm Time |
| `ring` |  0  | 1 | Alarm signal |
| `end_ring` |  I  | 1 | Stop Alarm |

## Simulation

[`testbench.v`](https://github.com/suoglu/Digital_Clock/blob/master/Sim/testbench.v) is used to simulate [`clockwork.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/clockwork.v) and [`date_module.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/date_module.v)

[`testbench_alarm.v`](https://github.com/suoglu/Digital_Clock/blob/master/Sim/testbench_alarm.v) is used to simulate [`alarm.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/alarm.v)

## Status

**Last simulation date:**

- [`clockwork.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/clockwork.v): 5 April 2020 with Icarus Verilog  
- [`date_module.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/date_module.v): 8 April 2020 with Icarus Verilog
- [`alarm.v`](https://github.com/suoglu/Digital_Clock/blob/master/Source/alarm.v): 28 April 2020 with Icarus Verilog
