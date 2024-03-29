# Digital Clock

## Contents of Readme

1. About
2. System Description
    1. Clockwork
    2. Date module
    3. Alarm module
    4. 24 hour to 12 hour converter
3. Port Descriptions
    1. Clockwork
    2. Date module
    3. Alarm module
    4. 24 hour to 12 hour converter
4. Simulation
5. Test
6. Status
7. Licence

[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-6C488A.svg)](https://gitlab.com/suoglu/digitalClock)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-3D76C2.svg)](https://github.com/suoglu/Digital_Clock)

---

## About

This project is a digital clock with date function. Currently works with 24h time format. It is still under development.

## System Description

Functionalities are seperated into different files, follows as:

- [`clockwork.v`](Source/clockwork.v): Hours, Minutes and Seconds  
- [`clockcalendar.v`](Source/clockcalendar.v): Days, Months and Years
- [`alarm.v`](Source/alarm.v): Alarm with an enable control
- [`h24toh12.v`](Source/h24toh12.v): 24 hour to 12 hour converter

Decimal modules always keep values in a decimal representation. e.g. fourteen is represented as *0x0E* in hexadecimal modules and as *0x14* in decimal modules.

**`clockWork`:**

This module provides basic time functionality. It uses a 1 Hz clock. This module does not provide a seperate reset signal, thus resetting should be done via time overwrite signal, `time_ow`.

In hexadecimal module, `clockWorkHex`, time is kept in 17 bits. Most significant 5 bits represent hour, following 6 bits represent minute and 6 least significant bits represent seconds.

In decimal module, `clockWorkDec`, time is kept in 20 bits. Most significant 6 bits represent hour, following 7 bits represent minute and 7 least significant bits represent seconds.

**`clockcalendar`:**

This module provides an "add-on" to provide date functionality. It uses current hour to keep track of date. Similar to `clockWork` module, resetting should be done via date overwrite signal, `date_ow`.

In hexadecimal module, `clockCalendarHex`, date is kept in 9 + year bits. Year bits determined via parameter `YEARRES`. Most significant 5 bits represent day, following 4 bits represent month and remaining bits represent year. Default value for `YEARRES` is 12 bits.

Two decimal modules are designed. At both of the modules, most significant 6 bits represent day, following 5 bits represent month and remaining bits represent year. In `clockCalendarDec4`, year is kept in 4 digits with 14 bits; and in `clockCalendarDec2`, year is kept in 2 digits with 8 bits.

**`alarm`:**

This module provides an "add-on" alarm. Alarm can be enabled via `en_in`. Signal `ring` is set when alarm is ring. And it is kept high until `end_ring` is set.

Alarm is not sensitive to the seconds.

File [`alarm.v`](Source/alarm.v) contains two modules `alarmHex` and `alarmDec`, one for hexadecimal other one for decimal modules. However only diffrence between those modules is the size of the registers.

**`h24Toh12`:**

Combinational "add-on" module to convert 24 hour format to 12 hour format.

## Port Descriptions

I: Input O: Output

In width column: Hexadecimal/Decimal

**`clockWork`:**

|   Port   |  Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
| `clk_1hz` |  I  | 1 | 1 Hz Clock |
| `time_in` |  I  | 17/20 | Time input |
| `time_out` |  O  | 17/20 | Time output |
| `time_ow` |  I  | 1 | Time overwrite |

**`clockcalendar`:**

|   Port   |  Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
| `clk` |  I  | 1 | System Clock |
| `hour_in` |  I  | 5/6 | Current hour |
| `date_in` |  I  | `YEARRES`+9/25/19 | Date input |
| `date_out` |  O  | `YEARRES`+9/25/19  | Date output |
| `date_ow` |  I  | 1 | Date overwrite |

`YEARRES` parameter determines the size of year register, default is 12 bits.

**`alarm`:**

|   Port   |  Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
| `clk` |  I  | 1 | System Clock |
| `rst` |  I  | 1 | System Reset |
| `en_in` |  I  | 1 | Enable Alarm |
| `time_in` |  I  | 11/13 | Time input (No seconds) |
| `time_set_in` |  I  | 11/13 | Time setting input (No seconds) |
| `set_time` |  I  | 1 | Set Alarm Time |
| `ring` |  0  | 1 | Alarm signal |
| `end_ring` |  I  | 1 | Stop Alarm |

**`h24Toh12`:**

|   Port   |  Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
| `hour24` |  I  | 5/6 | Hour in 24 hour format |
| `nAM_PM` |  O  | 1 | AM/PM indicator, High when PM |
| `hour12` |  O  | 4/5 | Hour in 12 hour format |

## Simulation

[`testbench_basic.v`](Sim/testbench_basic.v) is used to simulate `clockWorkHex` @  [`clockwork.v`](Source/clockwork.v) and `clockCalendarHex` @ [`clockcalendar.v`](Source/clockcalendar.v)

[`testbench_alarm.v`](testbench_alarm.v) is used to simulate `alarmHex` @ [`alarm.v`](Source/alarm.v)

[`testbench_h24h12.v`](testbench_h24h12.v) is used to simulate `h24Toh12Hex` and `h24Toh12Dec` @ [`h24toh12.v`](Source/h24toh12.v)

[`testbench_decClkwork.v`](Sim/testbench_decClkwork.v) is used to simulate `clockWorkDec` @  [`clockwork.v`](Source/clockwork.v)

[`testbench_decCal.v`](Sim/testbench_decCal.v) is used to simulate `clockCalendarDec4` and `clockCalendarDec2` @ [`clockcalendar.v`](Source/clockcalendar.v)

## Test

### Test 1 Hex modules (on 20 March 2021)

Hexadecimal modules in [`clockwork.v`](Source/clockwork.v), [`clockcalendar.v`](Source/clockcalendar.v), [`alarm.v`](Source/alarm.v) and [`h24toh12.v`](Source/h24toh12.v) are tested with [`testboard_main.v`](Test/testboard_main.v) and [`Basys3.xdc`](Test/Basys3.xdc). Special cases and a few examples of orinary cases are tested.

**States:**

Test board have four states; IDLE, get date, get time and get alarm. In IDLE state is the default state where system works. Other three states used to change/set time and date information.

**I/O:**

Eight rightmost switches are reserved to get data from user. How many switches actually used depends on entered data. Eight leftmost switches reserved for configurations. Leftmost switch (`SW[15]`) is used to control hour format, 12h or 24h. Following three switches (`sw[14:12]`) used to select seven segment display (ssd) data in IDLE state. In other states, values if data switches (`sw[7:0]`) are shown. Table below shows mapping of `sw[14:12]` values to display content. Following switch (`SW[11]`) is used to enable alarm.

| `sw[14:12]` value | Displayed Content | Active Digits |
| :------: | :----: | :----: |
| 0 | Seconds |  Right Half  |
| 1 |  Hours:Minutes  |  All  |
| 2 |  Day:Month  |  All  |
| 3 |  Year  |  Right Half  |
| 4 |  Switch val  |  Right Half  |
| ? |  Empty  |  None  |

Dots on the ssd is used to indicate  AM/PM.

LEDs are used to show status information. Two leftmost LEDs show `stepCounter` (will be explaned later), following two LEDs show state informarion. Rightmost LED is used as alarm. Remaining LEDs tied to ground.

In IDLE mode all buttons except center and down one used to change the state of the test board. Center button is reset and down button used to silence alarm. Up button used to set time, left button used to set date and right button used to set alarm time. While getting data, any button (other than center) will advence to next step. Which part of the data is gathered depends on which state and step are we. Table below shows gathered data:

| `stepCounter` | `getTIME` | `getDATE` | `setALRM` |
| :------: | :----: | :----: | :----: |
| 0 | Hour (5 bits) | Year (7 bits) | Hour (5 bits) |
| 1 | Minute (6 bits) | Month (4 bits) | Minute (6 bits) |
| 2 | - | Day (6 bits) | - |

Anything that is not taken from the switches conneced to 0.

**Tested Cases**:

- `clockWorkHex` @ [`clockwork.v`](Source/clockwork.v):
  - Seconds in Minute
  - New Minute
  - New Hour
  - New Day
- `clockCalendarHex` @ [`clockcalendar.v`](Source/clockcalendar.v):
  - New Year
  - Ordinary February
  - Special Case February
  - End of a random month with 30 days before July
  - End of a random month with 31 days before July
  - End of a random month with 30 days after August
  - End of a random month with 31 days after August
- `alarm` @ [`alarm.v`](Source/alarm.v):
  - Tested for one case when enabled and one disabled.
- `h24Toh12Hex` @ [`h24toh12.v`](Source/h24toh12.v):
  - Two random cases for both AM and PM tested.
  - Midnight and Noon are tested.

**(Synthesized) Utilization on Artix-7 XC7A35T-1CPG236C**:

- `clockWorkHex` @ [`clockwork.v`](Source/clockwork.v):
  - Slice LUTs: 80
  - Slice Registers: 51
- `clockCalendarHex` @ [`clockcalendar.v`](Source/clockcalendar.v):
  - Slice LUTs: 106
  - Slice Registers: 78
- `alarmHex` @ [`alarm.v`](Source/alarm.v):
  - Slice LUTs: 6
  - Slice Registers: 13
- `h24Toh12Hex` @ [`h24toh12.v`](Source/h24toh12.v):
  - Slice LUTs: 2

### Test 2 Dec modules (on 22 April 2021)

[`testmodule_dec.v`](Test/testmodule_dec.v) includes a test module for
`clockWorkDec` @ [`clockwork.v`](Source/clockwork.v),  `alarmDec` @ [`alarm.v`](Source/alarm.v), `h24Toh12Dec` @ [`h24toh12.v`](Source/h24toh12.v), and `clockCalendar2Dec` and `clockCalendar4Dec` @ [`clockcalendar.v`](Source/clockcalendar.v). Similar logic as Hexadecimal module tests ([`testboard_main.v`](Test/testboard_main.v)) and same constrains ([`Basys3.xdc`](Test/Basys3.xdc)) is used for testing. Register sizes changed accordingly. Each module added as a seperate block and connected to test module in block desing. One can refer Test 1 for more information about test logic.

**Tested Cases**:

- `clockWorkDec` @ [`clockwork.v`](Source/clockwork.v):
  - Seconds in Minute
  - New Minute
  - New Hour
  - New Day
- `clockCalendar2Dec` @ [`clockcalendar.v`](Source/clockcalendar.v):
  - New Year
  - Ordinary February
  - Special Case February
  - End of a random month with 30 days before July
  - End of a random month with 31 days before July
  - End of a random month with 30 days after August
  - End of a random month with 31 days after August
- `alarmDec` @ [`alarm.v`](Source/alarm.v):
  - Tested for one case when enabled and one disabled.
- `h24Toh12Dec` @ [`h24toh12.v`](Source/h24toh12.v):
  - Two random cases for both AM and PM tested.
  - Midnight and Noon are tested.

**Note:** `clockCalendar4Dec` module did not update it's values with `date_ow` singnal in test.

**(Synthesized) Utilization on Artix-7 XC7A35T-1CPG236C**:

- `clockWorkDec` @ [`clockwork.v`](Source/clockwork.v):
  - Slice LUTs: 90
  - Slice Registers: 60
- `clockCalendar2Dec` @ [`clockcalendar.v`](Source/clockcalendar.v):
  - Slice LUTs: 109
  - Slice Registers: 75
- `clockCalendar4Dec` @ [`clockcalendar.v`](Source/clockcalendar.v):
  - Slice LUTs: 161
  - Slice Registers: 93
- `alarmDec` @ [`alarm.v`](Source/alarm.v):
  - Slice LUTs: 7
  - Slice Registers: 15
- `h24Toh12Dec` @ [`h24toh12.v`](Source/h24toh12.v):
  - Slice LUTs: 4

## Status

**Last Simulation:**

- [`clockwork.v`](Source/clockwork.v): 21 April 2021 with [Icarus Verilog](http://iverilog.icarus.com/)
- [`clockcalendar.v`](Source/clockcalendar.v): 22 April 2021 with [Icarus Verilog](http://iverilog.icarus.com/)
- [`alarm.v`](Source/alarm.v): 28 April 2020 with [Icarus Verilog](http://iverilog.icarus.com/)
- [`h24toh12.v`](Source/h24toh12.v): 21 April 2021 with [Icarus Verilog](http://iverilog.icarus.com/)

**Last Test:**

- Hexadecimal modules: 20 March 2021, on [Digilent Basys 3](https://reference.digilentinc.com/reference/programmable-logic/basys-3/reference-manual).

- Decimal modules: 22 April 2021, on [Digilent Basys 3](https://reference.digilentinc.com/reference/programmable-logic/basys-3/reference-manual).

## Licence

CERN Open Hardware Licence Version 2 - Weakly Reciprocal
