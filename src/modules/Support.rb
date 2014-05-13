# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File:	modules/Support.ycp
# Package:	Configuration of support
# Summary:	Support settings, input and output functions
# Authors:	Michal Zugec <mzugec@novell.com>
#
# $Id: Support.ycp 41350 2007-10-10 16:59:00Z dfiser $
#
# Representation of the configuration of support.
# Input and output routines.
require "yast"

module Yast
  class SupportClass < Module
    def main
      Yast.import "UI"
      textdomain "support"

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"
      Yast.import "Message"
      Yast.import "Map"
      Yast.import "PackageSystem"
      Yast.import "Label"
      include Yast::Logger

      # Data was modified?
      @modified = false


      @proposal_valid = false

      # Write only, used during autoinstallation.
      # Don't run services and SuSEconfig, it's all done at one place.
      @write_only = false

      # Abort function
      # return boolean return true if abort
      @AbortFunction = fun_ref(method(:Modified), "boolean ()")

      # root password for running supportconfig if module run as non-root
      @root_pw = nil

      @pwd_file = nil

      # content of /etc/supportconfig.conf
      @configuration = {}

      # options parsed from configuration map
      @options = {}

      # command line parameters for support
      @use_defaults = false
      @full_listening = false
      @exclude_disk_scan = false
      @search_for_edir = false
      @full_logging = false
      @minimal_logs = false
      @include_slp = false
      @rpm_check = false
      @additional_logs = false
      @novell_number = ""

      @log_files = {}
      #global string created_directory="";

      @browser = nil
    end

    def CheckRootPw(pw)
      if @pwd_file == nil
        @pwd_file = Ops.add(
          Convert.to_string(SCR.Read(path(".target.tmpdir"))),
          "/pwd_file"
        )
      end
      SCR.Execute(
        path(".target.bash"),
        Builtins.sformat("test -e %1 || touch %1", @pwd_file)
      )
      SCR.Execute(
        path(".target.bash"),
        Builtins.sformat("chmod 600 %1", @pwd_file)
      )
      SCR.Write(path(".target.string"), @pwd_file, Ops.add(pw, "\n"))
      exit = Convert.to_integer(
        SCR.Execute(
          path(".target.bash"),
          Builtins.sformat("cat %1 | su -c 'echo 0'", @pwd_file)
        )
      )
      SCR.Write(path(".target.string"), @pwd_file, "")
      success = exit == 0
      Builtins.y2milestone("Root password check: %1", success)
      @root_pw = pw if success
      success
    end

    def WhoAmI
      if Ops.less_or_equal(
          Convert.to_integer(SCR.Read(path(".target.size"), "/usr/bin/id")),
          0
        )
        Builtins.y2warning("/usr/bin/id not existing, supposing to be root")
        return 0
      end

      out = Convert.to_map(
        SCR.Execute(path(".target.bash_output"), "/usr/bin/id --user")
      )
      lines = Builtins.splitstring(Ops.get_string(out, "stdout", ""), "\n")
      strid = Ops.get(lines, 0, "")
      id = Builtins.tointeger(strid)
      return 0 if id == nil
      id
    end

    def AskForRootPwd
      while @root_pw == nil
        UI.OpenDialog(
          VBox(
            Label(_("To continue, enter root password")),
            Password(Id(:passwd), _("root Password")),
            ButtonBox(
              PushButton(
                Id(:ok),
                Opt(:okButton, :default, :key_F10),
                Label.OKButton
              ),
              PushButton(
                Id(:cancel),
                Opt(:cancelButton, :key_F9),
                Label.CancelButton
              )
            )
          )
        )
        input = Convert.to_symbol(UI.UserInput)
        pw = Convert.to_string(UI.QueryWidget(Id(:passwd), :Value))
        UI.CloseDialog
        return false if input == :cancel
        Report.Error(_("Password incorrect")) if !CheckRootPw(pw)
      end
      true
    end

    # Abort function
    # @return [Boolean] return true if abort
    def Abort
      return @AbortFunction.call == true if @AbortFunction != nil
      false
    end

    # Data was modified?
    # @return true if modified
    def Modified
      Builtins.y2debug("modified=%1", @modified)
      @modified
    end

    # Mark as modified, for Autoyast.
    def SetModified(value)
      @modified = true

      nil
    end

    def ProposalValid
      @proposal_valid
    end

    def SetProposalValid(value)
      @proposal_valid = value

      nil
    end

    # @return true if module is marked as "write only" (don't start services etc...)
    def WriteOnly
      @write_only
    end

    # Set write_only flag (for autoinstalation).
    def SetWriteOnly(value)
      @write_only = value

      nil
    end


    def SetAbortFunction(function)
      function = deep_copy(function)
      @AbortFunction = deep_copy(function)

      nil
    end

    def GetParameterList
      parameters = ""
      parameters = Builtins.sformat("%1 %2", parameters, "-D") if @use_defaults
      if @full_listening
        parameters = Builtins.sformat("%1 %2", parameters, "-L")
      end
      if @exclude_disk_scan
        parameters = Builtins.sformat("%1 %2", parameters, "-d")
      end
      if @search_for_edir
        parameters = Builtins.sformat("%1 %2", parameters, "-e")
      end
      parameters = Builtins.sformat("%1 %2", parameters, "-A") if @full_logging
      parameters = Builtins.sformat("%1 %2", parameters, "-m") if @minimal_logs
      parameters = Builtins.sformat("%1 %2", parameters, "-s") if @include_slp
      parameters = Builtins.sformat("%1 %2", parameters, "-v") if @rpm_check
      parameters = Builtins.sformat("%1 %2", parameters, "-l") if @additional_logs
      if Ops.greater_than(Builtins.size(@novell_number), 0)
        parameters = Builtins.sformat(
          "%1 %2 %3",
          parameters,
          "-r",
          @novell_number
        )
      end
      Builtins.y2milestone("Create parameter list : %1", parameters)
      parameters
    end

    # Settings: Define all variables needed for configuration of support
    # TODO FIXME: Define all the variables necessary to hold
    # TODO FIXME: the configuration here (with the appropriate
    # TODO FIXME: description)
    # TODO FIXME: For example:
    #   /**
    #    * List of the configured cards.
    #    */
    #   list cards = [];
    #
    #   /**
    #    * Some additional parameter needed for the configuration.
    #    */
    #   boolean additional_parameter = true;

    # Read all support settings
    # @return true on success
    def Read
      # Support read dialog caption
      caption = _("Initializing Support Configuration")

      # make sure supportconfig.conf exists
      # the call does not work as non-root
      if Support.WhoAmI == 0 && ! FileUtils.Exists("/etc/supportconfig.conf")
        log.info "Creating new /etc/supportconfig.conf file"
        SCR.Execute(path(".target.bash"), "/sbin/supportconfig -C");
      end

      @configuration = Convert.to_map(SCR.Read(path(".etc.supportconfig.all")))
      Builtins.foreach(Ops.get_list(@configuration, "value", [])) do |row|
        Ops.set(
          @options,
          Ops.get_string(row, "name", ""),
          Ops.get_string(row, "value", "")
        )
      end
      # Error message
      Report.Error(Message.CannotReadCurrentSettings) if false

      # read current settings
      if PackageSystem.Installed("MozillaFirefox")
        @browser = "firefox"
      elsif PackageSystem.Installed("kde4-konqueror") ||
          PackageSystem.Installed("kdebase3")
        @browser = "konqueror"
      elsif PackageSystem.Installed("opera")
        @browser = "opera"
      else
        Builtins.y2error("Couldn't find any supported browser installed.")
      end
      # Error message
      Report.Error(Message.CannotReadCurrentSettings) if false

      return false if Abort()
      @log_files = {
        "tmp_dir" => Convert.to_string(SCR.Read(path(".target.tmpdir")))
      }
      @modified = false
      true
    end

    # Write all support settings
    # @return true on success
    def Write
      # Support read dialog caption
      caption = _("Saving Support Configuration")

      # TODO FIXME And set the right number of stages
      steps = 2

      sl = 500
      Builtins.sleep(sl)

      # TODO FIXME Names of real stages
      # We do not set help text here, because it was set outside
      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/2
          _("Write the settings"),
          # Progress stage 2/2
          _("Run SuSEconfig")
        ],
        [
          # Progress step 1/2
          _("Writing the settings..."),
          # Progress step 2/2
          _("Running SuSEconfig..."),
          # Progress finished
          _("Finished")
        ],
        ""
      )

      # write settings
      return false if Abort()
      Progress.NextStage
      Builtins.sleep(sl)

      # run SuSEconfig
      return false if Abort()
      Progress.NextStage
      # Error message
      Report.Error(Message.SuSEConfigFailed) if false
      Builtins.sleep(sl)

      return false if Abort()
      # Progress finished
      Progress.NextStage
      Builtins.sleep(sl)

      return false if Abort()
      true
    end

    def WriteConfig
      Builtins.y2milestone("Writing /etc/supportconfig.conf configuration")
      new_config = []
      used_options = []
      Builtins.foreach(Ops.get_list(@configuration, "value", [])) do |row|
        Ops.set(
          row,
          "value",
          Ops.get_string(@options, Ops.get_string(row, "name", ""), "")
        )
        new_config = Builtins.add(new_config, row)
        used_options = Builtins.add(
          used_options,
          Ops.get_string(row, "name", "")
        )
      end
      Builtins.foreach(
        Convert.convert(
          Map.Keys(@options),
          :from => "list",
          :to   => "list <string>"
        )
      ) do |key|
        if !Builtins.contains(used_options, key)
          Builtins.y2milestone(
            "new option (not in old configuration) %1=%2",
            key,
            Ops.get_string(@options, key, "")
          )
          new_config = Builtins.add(
            new_config,
            {
              "name"    => key,
              "value"   => Ops.get_string(@options, key, ""),
              "comment" => "",
              "kind"    => "value",
              "type"    => 1
            }
          )
        end
      end
      Ops.set(@configuration, "value", new_config)
      SCR.Write(path(".etc.supportconfig.all"), @configuration)
      Builtins.y2milestone(
        "Write /etc/supportconfig.conf :%1",
        SCR.Write(path(".etc.supportconfig"), nil)
      )
      true
    end

    # Get all support settings from the first parameter
    # (For use by autoinstallation.)
    # @param [Hash] settings The YCP structure to be imported.
    # @return [Boolean] True on success
    def Import(settings)
      settings = deep_copy(settings)
      # TODO FIXME: your code here (fill the above mentioned variables)...
      true
    end

    # Dump the support settings to a single map
    # (For use by autoinstallation.)
    # @return [Hash] Dumped settings (later acceptable by Import ())
    def Export
      # TODO FIXME: your code here (return the above mentioned variables)...
      {}
    end

    # Create a textual summary and a list of unconfigured cards
    # @return summary of the current configuration
    def Summary
      # TODO FIXME: your code here...
      # Configuration summary text for autoyast
      [_("Configuration summary..."), []]
    end

    # Create an overview table with all configured cards
    # @return table items
    def Overview
      # TODO FIXME: your code here...
      []
    end

    # Return packages needed to be installed and removed during
    # Autoinstallation to insure module has all needed software
    # installed.
    # @return [Hash] with 2 lists.
    def AutoPackages
      # TODO FIXME: your code here...
      { "install" => [], "remove" => [] }
    end

    publish :function => :Modified, :type => "boolean ()"
    publish :variable => :root_pw, :type => "string"
    publish :variable => :pwd_file, :type => "string"
    publish :function => :CheckRootPw, :type => "boolean (string)"
    publish :function => :WhoAmI, :type => "integer ()"
    publish :function => :AskForRootPwd, :type => "boolean ()"
    publish :function => :Abort, :type => "boolean ()"
    publish :function => :SetModified, :type => "void (boolean)"
    publish :function => :ProposalValid, :type => "boolean ()"
    publish :function => :SetProposalValid, :type => "void (boolean)"
    publish :function => :WriteOnly, :type => "boolean ()"
    publish :function => :SetWriteOnly, :type => "void (boolean)"
    publish :function => :SetAbortFunction, :type => "void (boolean ())"
    publish :variable => :options, :type => "map"
    publish :variable => :use_defaults, :type => "boolean"
    publish :variable => :full_listening, :type => "boolean"
    publish :variable => :exclude_disk_scan, :type => "boolean"
    publish :variable => :search_for_edir, :type => "boolean"
    publish :variable => :full_logging, :type => "boolean"
    publish :variable => :minimal_logs, :type => "boolean"
    publish :variable => :include_slp, :type => "boolean"
    publish :variable => :rpm_check, :type => "boolean"
    publish :variable => :additional_logs, :type => "boolean"
    publish :variable => :novell_number, :type => "string"
    publish :variable => :log_files, :type => "map <string, any>"
    publish :variable => :browser, :type => "string"
    publish :function => :GetParameterList, :type => "string ()"
    publish :function => :Read, :type => "boolean ()"
    publish :function => :Write, :type => "boolean ()"
    publish :function => :WriteConfig, :type => "boolean ()"
    publish :function => :Import, :type => "boolean (map)"
    publish :function => :Export, :type => "map ()"
    publish :function => :Summary, :type => "list ()"
    publish :function => :Overview, :type => "list ()"
    publish :function => :AutoPackages, :type => "map ()"
  end

  Support = SupportClass.new
  Support.main
end
