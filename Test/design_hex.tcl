
################################################################
# This is a generated script based on design: design_hex
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_hex_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# alarm, board, clockCalendarHex, clockWorkHex, h24Toh12Hex

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a35tcpg236-1
   set_property BOARD_PART digilentinc.com:basys3:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_hex

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
alarm\
board\
clockCalendarHex\
clockWorkHex\
h24Toh12Hex\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set an [ create_bd_port -dir O -from 3 -to 0 -type data an ]
  set btnD [ create_bd_port -dir I -type data btnD ]
  set btnL [ create_bd_port -dir I -type data btnL ]
  set btnR [ create_bd_port -dir I -type data btnR ]
  set btnU [ create_bd_port -dir I -type data btnU ]
  set clk [ create_bd_port -dir I -type clk -freq_hz 100000000 clk ]
  set dp [ create_bd_port -dir O -type data dp ]
  set led [ create_bd_port -dir O -from 15 -to 0 -type data led ]
  set rst [ create_bd_port -dir I -type rst rst ]
  set seg [ create_bd_port -dir O -from 6 -to 0 -type data seg ]
  set sw [ create_bd_port -dir I -from 15 -to 0 -type data sw ]

  # Create instance: alarm_0, and set properties
  set block_name alarm
  set block_cell_name alarm_0
  if { [catch {set alarm_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $alarm_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: board_0, and set properties
  set block_name board
  set block_cell_name board_0
  if { [catch {set board_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $board_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: clockCalendarHex_0, and set properties
  set block_name clockCalendarHex
  set block_cell_name clockCalendarHex_0
  if { [catch {set clockCalendarHex_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $clockCalendarHex_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: clockWorkHex_0, and set properties
  set block_name clockWorkHex
  set block_cell_name clockWorkHex_0
  if { [catch {set clockWorkHex_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $clockWorkHex_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: h24Toh12Hex_0, and set properties
  set block_name h24Toh12Hex
  set block_cell_name h24Toh12Hex_0
  if { [catch {set h24Toh12Hex_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $h24Toh12Hex_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create port connections
  connect_bd_net -net Net [get_bd_ports clk] [get_bd_pins alarm_0/clk] [get_bd_pins board_0/clk] [get_bd_pins clockCalendarHex_0/clk]
  connect_bd_net -net Net1 [get_bd_ports rst] [get_bd_pins alarm_0/rst] [get_bd_pins board_0/rst]
  connect_bd_net -net alarm_0_ring [get_bd_pins alarm_0/ring] [get_bd_pins board_0/alarm_ring]
  connect_bd_net -net board_0_alarm_en_in [get_bd_pins alarm_0/en_in] [get_bd_pins board_0/alarm_en_in]
  connect_bd_net -net board_0_alarm_end_ring [get_bd_pins alarm_0/end_ring] [get_bd_pins board_0/alarm_end_ring]
  connect_bd_net -net board_0_alarm_set_time [get_bd_pins alarm_0/set_time] [get_bd_pins board_0/alarm_set_time]
  connect_bd_net -net board_0_alarm_time_in [get_bd_pins alarm_0/time_in] [get_bd_pins board_0/alarm_time_in]
  connect_bd_net -net board_0_alarm_time_set_in [get_bd_pins alarm_0/time_set_in] [get_bd_pins board_0/alarm_time_set_in]
  connect_bd_net -net board_0_an [get_bd_ports an] [get_bd_pins board_0/an]
  connect_bd_net -net board_0_calender_date_in [get_bd_pins board_0/calender_date_in] [get_bd_pins clockCalendarHex_0/date_in]
  connect_bd_net -net board_0_calender_date_ow [get_bd_pins board_0/calender_date_ow] [get_bd_pins clockCalendarHex_0/date_ow]
  connect_bd_net -net board_0_calender_hour_in [get_bd_pins board_0/calender_hour_in] [get_bd_pins clockCalendarHex_0/hour_in]
  connect_bd_net -net board_0_clk_1hz [get_bd_pins board_0/clk_1hz] [get_bd_pins clockWorkHex_0/clk_1hz]
  connect_bd_net -net board_0_clock_time_in [get_bd_pins board_0/clock_time_in] [get_bd_pins clockWorkHex_0/time_in]
  connect_bd_net -net board_0_clock_time_ow [get_bd_pins board_0/clock_time_ow] [get_bd_pins clockWorkHex_0/time_ow]
  connect_bd_net -net board_0_dp [get_bd_ports dp] [get_bd_pins board_0/dp]
  connect_bd_net -net board_0_h24Toh12_hour24 [get_bd_pins board_0/h24Toh12_hour24] [get_bd_pins h24Toh12Hex_0/hour24]
  connect_bd_net -net board_0_led [get_bd_ports led] [get_bd_pins board_0/led]
  connect_bd_net -net board_0_seg [get_bd_ports seg] [get_bd_pins board_0/seg]
  connect_bd_net -net btnD_1 [get_bd_ports btnD] [get_bd_pins board_0/btnD]
  connect_bd_net -net btnL_1 [get_bd_ports btnL] [get_bd_pins board_0/btnL]
  connect_bd_net -net btnR_1 [get_bd_ports btnR] [get_bd_pins board_0/btnR]
  connect_bd_net -net btnU_1 [get_bd_ports btnU] [get_bd_pins board_0/btnU]
  connect_bd_net -net clockCalendarHex_0_date_out [get_bd_pins board_0/calender_date_out] [get_bd_pins clockCalendarHex_0/date_out]
  connect_bd_net -net clockWorkHex_0_time_out [get_bd_pins board_0/clock_time_out] [get_bd_pins clockWorkHex_0/time_out]
  connect_bd_net -net h24Toh12Hex_0_hour12 [get_bd_pins board_0/h24Toh12_hour12] [get_bd_pins h24Toh12Hex_0/hour12]
  connect_bd_net -net h24Toh12Hex_0_nAM_PM [get_bd_pins board_0/h24Toh12_nAM_PM] [get_bd_pins h24Toh12Hex_0/nAM_PM]
  connect_bd_net -net sw_1 [get_bd_ports sw] [get_bd_pins board_0/sw]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


