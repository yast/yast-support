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

# File:	clients/support.ycp
# Package:	Configuration of support
# Summary:	Main file
# Authors:	Michal Zugec <mzugec@novell.com>
#
# $Id: support.ycp 27914 2006-02-13 14:32:08Z locilka $
#
# Main file for support configuration. Uses all other files.
module Yast
  module SupportDialogsInclude
    def initialize_support_dialogs(include_target)
      textdomain "support"

      Yast.import "Label"
      Yast.import "Report"
      Yast.import "Wizard"
      Yast.import "Support"
      Yast.import "Map"
      Yast.include include_target, "support/helps.rb"
      Yast.include include_target, "support/supportconfig_conf.rb"
    end

    def OverviewDialog
      # Command line parameters dialog caption
      caption = _("Supportconfig Overview Dialog")

      # Support configure1 dialog contents
      contents = HBox(
        HStretch(),
        VBox(
          Frame(
            _("Open SUSE Support Center"),
            VBox(
              HStretch(),
              Left(
                Label(
                  _(
                    "This will start a browser connecting to the SUSE Support Center Portal."
                  )
                )
              ),
              HBox(
                HStretch(),
                HStretch(),
                HStretch(),
                HStretch(),
                MinWidth(25, PushButton(Id(:browser), _("Open"))),
                HStretch(),
                HStretch(),
                HStretch(),
                HStretch()
              )
            )
          ),
          VSpacing(2),
          Frame(
            Opt(:hstretch),
            _("Collect Data"),
            VBox(
              HStretch(),
              Left(
                Label(
                  _(
                    "This will create a tarball containing the collected log files."
                  )
                )
              ),
              HBox(
                HStretch(),
                HStretch(),
                HStretch(),
                HStretch(),
                MinWidth(
                  25,
                  PushButton(Id(:tarball), _("Create report tarball"))
                ),
                HStretch(),
                HStretch(),
                HStretch(),
                HStretch()
              )
            )
          ),
          VSpacing(2),
          Frame(
            Opt(:hstretch),
            _("Upload Data"),
            VBox(
              HStretch(),
              Label(
                _("This will upload the collected logs to the specified URL.")
              ),
              HBox(
                HStretch(),
                HStretch(),
                HStretch(),
                HStretch(),
                MinWidth(25, PushButton(Id(:upload), _("Upload"))),
                HStretch(),
                HStretch(),
                HStretch(),
                HStretch()
              )
            )
          )
        ),
        HStretch()
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "overview", ""),
        Label.BackButton,
        Label.FinishButton
      )

      Wizard.DisableBackButton

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :abort || ret == :cancel || ret == :tarball || ret == :upload ||
            ret == :next
          break
        elsif ret == :browser
          if Support.browser == nil
            Popup.Error(_("Could not find any installed browser."))
          else
            url = "'http://scc.suse.com/tickets'"
            if 0 ==
                SCR.Execute(
                  path(".target.bash"),
                  "env|grep LOGNAME|cut -d'=' -f2- | grep root"
                )
              if Popup.ContinueCancel(
                  Builtins.sformat(
                    _(
                      "YaST will run a Web browser as superuser. Consider\n" +
                        "running it as a non-provileged user and entering the URL\n" +
                        "%1.\n" +
                        "Start Web browser?\n"
                    ),
                    url
                  )
                )
                Builtins.y2milestone(
                  "Executing browser %1 with URL %2",
                  Support.browser,
                  url
                )
                SCR.Execute(
                  path(".target.bash"),
                  Builtins.sformat("%1 %2", Support.browser, url)
                )
              end
            else
              Builtins.y2milestone(
                "Executing browser %1 with URL %2",
                Support.browser,
                url
              )
              SCR.Execute(
                path(".target.bash"),
                Builtins.sformat(
                  "su $(env|grep LOGNAME|cut -d'=' -f2-) -c \"%1 %2\"",
                  Support.browser,
                  url
                )
              )
            end
          end
        end
      end
      ret = :abort if ret == :cancel
      deep_copy(ret)
    end

    def UploadDialog(data_prepared)
      caption = _("Supportconfig Upload Dialog")
      url = Builtins.deletechars(
        Ops.get_string(Support.options, "VAR_OPTION_UPLOAD_TARGET", ""),
        "'"
      )
      Builtins.y2milestone("URL value from /etc/supportconfig.conf : %1", url)
      Builtins.y2milestone("%1", Support.log_files)
      dir_to_save = Ops.get_string(
        Convert.convert(
          SCR.Execute(path(".target.bash_output"), "echo ~|tr -d '\n'"),
          :from => "any",
          :to   => "map <string, any>"
        ),
        "stdout",
        ""
      )
      if dir_to_save == "/root"
        dir_to_save = "/var/log"
      end
      # Support configure1 dialog contents
      load_save = nil
      if data_prepared
        load_save = Left(
          CheckBoxFrame(
            Id(:save),
            _("Save as"),
            true,
            HBox(
              InputField(Id(:save_dir), _("Directory to Save"), dir_to_save),
              VBox(Label(""), PushButton(Id(:browse), Label.BrowseButton))
            )
          )
        )
      else
        load_save = Left(
          HBox(
            InputField(
              Id(:tarball_file),
              _("Package with log files"),
              Ops.get_string(Support.log_files, "tarball", "")
            ),
            VBox(Label(""), PushButton(Id(:browse), Label.BrowseButton))
          )
        )
      end

      contents = Frame(
        "",
        VBox(
          load_save,
          CheckBoxFrame(
            Id(:upload),
            _("Upload log files tarball to URL"),
            true,
            Left(InputField(Id(:url), _("Upload Target"), url))
          )
        )
      )
      help = data_prepared ?
        Ops.get_string(@HELPS, "upload_save", "") :
        Ops.get_string(@HELPS, "upload_select", "")
      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.BackButton,
        Label.NextButton
      )

      ret = nil
      while true
        ret = UI.UserInput
        break if ret == :abort || ret == :back
        if ret == :next
          if !data_prepared
            unpack = Builtins.sformat(
              "cd %1 && tar xvf %2",
              Ops.get_string(Support.log_files, "tmp_dir", ""),
              Ops.get_string(Support.log_files, "tarball", "")
            )
            Builtins.y2milestone(
              "unpack %1",
              SCR.Execute(path(".target.bash_output"), unpack)
            ) 
            #	  break;
          end
          Builtins.y2milestone("data_prepared %1", data_prepared)
          Builtins.y2milestone("Support::log_files %1", Support.log_files)
          command = Builtins.sformat(
            "supportconfig %1 -f %2",
            Support.GetParameterList,
            Ops.get_string(Support.log_files, "tmp_dir", "")
          )
          if Convert.to_boolean(UI.QueryWidget(:upload, :Value))
            url2 = Convert.to_string(UI.QueryWidget(:url, :Value))
            if Ops.greater_than(Builtins.size(url2), 0) #{
              command = Builtins.sformat("%1 -u -U '%2'", command, url2)
            end 
            #	   }
          end
          if Support.WhoAmI != 0
            return :back if !Support.AskForRootPwd
            id = Support.WhoAmI
            SCR.Write(
              path(".target.string"),
              Support.pwd_file,
              Ops.add(Support.root_pw, "\n")
            )
            command = Builtins.sformat(
              "cat %2 | su -c '%1'",
              command,
              Support.pwd_file
            )
          end
          Builtins.y2milestone("executing %1", command)
          output = Convert.convert(
            SCR.Execute(path(".target.bash_output"), command),
            :from => "any",
            :to   => "map <string, any>"
          )
          Builtins.y2milestone("output %1", output)
          if Support.WhoAmI != 0
            SCR.Write(path(".target.string"), Support.pwd_file, "")
          end
          if Ops.get_integer(output, "exit", -1) != 0
            Report.Error(
              Builtins.sformat("%1 : %2", _("Cannot write settings"), output)
            )
          else
            command = Builtins.sformat(
              "find \"%1\" -type f -name \"%2*\"|grep -v \".md5$\" | tr -d '\n'",
              Ops.get_string(Support.log_files, "tmp_dir", ""),
              Ops.get_string(Support.log_files, "log_dir", "")
            )
            Builtins.y2milestone("command %1", command)
            output = Convert.convert(
              SCR.Execute(path(".target.bash_output"), command),
              :from => "any",
              :to   => "map <string, any>"
            )
            if Ops.get_integer(output, "exit", -1) != 0
              Report.Error(
                Builtins.sformat("%1 : %2", _("Cannot write settings."), output)
              )
            else
              if Ops.greater_than(
                  Builtins.size(Ops.get_string(output, "stdout", "")),
                  0
                )
                Ops.set(
                  Support.log_files,
                  "tarball",
                  Ops.get_string(output, "stdout", "")
                )
                Builtins.y2milestone(
                  "input tarball : %1",
                  Ops.get_string(Support.log_files, "tarball", "")
                )
                if data_prepared &&
                    Convert.to_boolean(UI.QueryWidget(:save, :Value))
                  tarball = Ops.get_string(Support.log_files, "tarball", "")
                  output_dir = Convert.to_string(
                    UI.QueryWidget(:save_dir, :Value)
                  )
                  command2 = Builtins.sformat(
                    "cp %1* '%2'",
                    tarball,
                    output_dir
                  )
                  Builtins.y2milestone(
                    "execute %1 : %2",
                    command2,
                    SCR.Execute(path(".target.bash_output"), command2)
                  )
                end
              else
                Builtins.y2error("Empty filename : %1", output)
              end
            end
          end
          break
        end
        if ret == :browse
          if data_prepared
            startdir = Convert.to_string(UI.QueryWidget(:save_dir, :Value))
            Builtins.y2milestone("startdir %1", startdir)
            save_dir = UI.AskForExistingDirectory(
              startdir,
              _("Choose Directory Where to Save Tarball")
            )
            if save_dir != nil && Ops.greater_than(Builtins.size(save_dir), 0)
              UI.ChangeWidget(:save_dir, :Value, save_dir) 
              #           Support::log_files["tmp_dir"]=save_dir;
            else
              Builtins.y2error("Empty or invalid logs tarball path")
            end
          else
            tarball_file = UI.AskForExistingFile(
              "/",
              "*.tgz *.tbz",
              _("Choose Log Files Tarball File")
            )
            if tarball_file != nil &&
                Ops.greater_than(Builtins.size(tarball_file), 0)
              UI.ChangeWidget(:tarball_file, :Value, tarball_file)
              Ops.set(Support.log_files, "tarball", tarball_file)
            else
              Builtins.y2error("Empty or invalid logs tarball path")
            end
          end
          next
        end
      end
      deep_copy(ret)
    end

    # Command line parameters dialog
    # @return dialog result
    def ParametersDialog
      # Command line parameters dialog caption
      caption = _("Supportconfig Parameters Configuration")

      items = [
        Item(
          Id(:full_listening),
          _("Create a full file listing from '/'"),
          Support.full_listening
        ),
        Item(
          Id(:exclude_disk_scan),
          _("Exclude detailed disk info and scans"),
          Support.exclude_disk_scan
        ),
        Item(
          Id(:search_for_edir),
          _("Search root filesystem for eDirectory instances"),
          Support.search_for_edir
        ),
        Item(
          Id(:include_slp),
          _("Include full SLP service lists"),
          Support.include_slp
        ),
        Item(
          Id(:rpm_check),
          _("Performs an rpm -V for each installed rpm"),
          Support.rpm_check
        ),
        Item(
          Id(:additional_logs),
          _("Include all log file lines, gather additional rotated logs"),
          Support.additional_logs
        )
      ]
      # Support configure1 dialog contents
      contents = VBox(
        Left(
          RadioButtonGroup(
            Id(:rb),
            VBox(
              Left(
                RadioButton(
                  Id(:use_defaults),
                  Opt(:notify),
                  _("Use Defaults (ignore /etc/supportconfig.conf)")
                )
              ),
              Left(
                RadioButton(
                  Id(:full_logging),
                  Opt(:notify),
                  _("Activates all support functions")
                )
              ),
              Left(
                RadioButton(
                  Id(:minimal_logs),
                  Opt(:notify),
                  _("Only gather a minimum amount of info")
                )
              ),
              Left(
                VBox(
                  RadioButton(
                    Id(:custom),
                    Opt(:notify),
                    _("Use Custom (Expert) Settings")
                  ),
                  PushButton(Id(:expert), _("Expert Settings"))
                )
              )
            )
          )
        ),
        MultiSelectionBox(Id(:options), _("Options"), items)
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "support_params", ""),
        Label.BackButton,
        Label.NextButton
      )

      if Support.use_defaults
        UI.ChangeWidget(:rb, :CurrentButton, :use_defaults)
      elsif Support.full_logging
        UI.ChangeWidget(:rb, :CurrentButton, :full_logging)
      elsif Support.minimal_logs
        UI.ChangeWidget(:rb, :CurrentButton, :minimal_logs)
      else
        UI.ChangeWidget(:rb, :CurrentButton, :custom)
      end

      #    Wizard::DisableBackButton();

      ret = nil
      while true
        UI.ChangeWidget(
          :expert,
          :Enabled,
          UI.QueryWidget(:rb, :CurrentButton) == :custom
        )

        ret = UI.UserInput

        if ret == :use_defaults || ret == :full_logging || ret == :minimal_logs ||
            ret == :custom
          next
        end

        # abort?
        if ret == :abort || ret == :cancel
          if ReallyAbort()
            break
          else
            next
          end
        elsif ret == :back
          break
        elsif ret == :next || ret == :expert
          selected = Convert.to_list(UI.QueryWidget(:options, :SelectedItems))
          Support.use_defaults = Builtins.contains(selected, :use_defaults)
          Support.full_listening = Builtins.contains(selected, :full_listening)
          Support.exclude_disk_scan = Builtins.contains(
            selected,
            :exclude_disk_scan
          )
          Support.search_for_edir = Builtins.contains(
            selected,
            :search_for_edir
          )
          Support.full_logging = Builtins.contains(selected, :full_logging)
          Support.minimal_logs = Builtins.contains(selected, :minimal_logs)
          Support.include_slp = Builtins.contains(selected, :include_slp)
          Support.rpm_check = Builtins.contains(selected, :rpm_check)
          Support.additional_logs = Builtins.contains(selected, :additional_logs)

          case Convert.to_symbol(UI.QueryWidget(:rb, :CurrentButton))
            when :use_defaults
              Support.use_defaults = true
            when :full_logging
              Support.full_logging = true
            when :minimal_logs
              Support.minimal_logs = true
            else
              Builtins.y2milestone("Custom settings")
          end
          break
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end

      deep_copy(ret)
    end

    # Overview dialog
    # @return dialog result
    def ExpertDialog
      # Support overview dialog caption
      caption = _("Supportconfig Expert Configuration")

      overview = Support.Overview

      bool_items = []
      #	list<term> table_items = [];
      Builtins.foreach(
        Convert.convert(
          Map.Keys(Support.options),
          :from => "list",
          :to   => "list <string>"
        )
      ) do |key|
        if !Builtins.issubstring(key, "VAR_OPTION")
          value = Ops.get_string(@support_descr, key, "")
          bool_items = Builtins.add(
            bool_items,
            Item(
              Id(key),
              Ops.greater_than(Builtins.size(value), 0) ?
                Builtins.sformat("%1 - %2", key, value) :
                key,
              Ops.get_string(Support.options, key, "") == "1"
            )
          )
        end
      end

      # FIXME table header
      contents = HBox(
        MultiSelectionBox(Id(:opt_msb), _("Default Options"), bool_items) #,
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "expert_params", ""),
        Label.BackButton,
        Label.NextButton
      )

      ret = nil
      while true
        ret = UI.UserInput

        # abort?
        if ret == :abort || ret == :cancel
          if ReallyAbort()
            break
          else
            next
          end
        elsif ret == :next
          Builtins.y2milestone(
            "store configuration for /etc/supportconfig.conf"
          )
          selected_items = Convert.to_list(
            UI.QueryWidget(Id(:opt_msb), :SelectedItems)
          )
          Builtins.foreach(
            Convert.convert(
              Map.Keys(Support.options),
              :from => "list",
              :to   => "list <string>"
            )
          ) do |key|
            val = Ops.get_string(Support.options, key, "")
            if !Builtins.issubstring(key, "VAR_OPTION")
              bool_val = Builtins.contains(selected_items, key)
              if (val == "1") != bool_val
                Builtins.y2milestone(
                  "value changed %1=%2, new value %3",
                  key,
                  val,
                  bool_val ? "1" : "0"
                )
                Ops.set(Support.options, key, bool_val ? "1" : "0")
              end
            end
          end
          break
        elsif ret == :back
          break
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end
      Builtins.y2milestone("%1", Support.options)
      Convert.to_symbol(ret)
    end

    # Configure2 dialog
    # @return dialog result
    def ContactDialog
      # Support configure2 dialog caption
      caption = _("Supportconfig Contact Configuration")

      # Support configure2 dialog contents
      contents = VBox(
        Frame(
          _("Contact Information"),
          VBox(
            Left(
              InputField(
                Id(:company),
                _("Company"),
                Ops.get_string(
                  Support.options,
                  "VAR_OPTION_CONTACT_COMPANY",
                  ""
                )
              )
            ),
            Left(
              InputField(
                Id(:email),
                _("Email Address"),
                Ops.get_string(Support.options, "VAR_OPTION_CONTACT_EMAIL", "")
              )
            ),
            Left(
              InputField(
                Id(:name),
                _("Name"),
                Ops.get_string(Support.options, "VAR_OPTION_CONTACT_NAME", "")
              )
            ),
            Left(
              InputField(
                Id(:phone),
                _("Phone Number"),
                Ops.get_string(Support.options, "VAR_OPTION_CONTACT_PHONE", "")
              )
            ),
            Left(
              InputField(
                Id(:storeid),
                _("Store ID"),
                Ops.get_string(
                  Support.options,
                  "VAR_OPTION_CONTACT_STOREID",
                  ""
                )
              )
            ),
            Left(
              InputField(
                Id(:terminalid),
                _("Terminal ID"),
                Ops.get_string(
                  Support.options,
                  "VAR_OPTION_CONTACT_TERMINALID",
                  ""
                )
              )
            ),
            Left(
              InputField(
                Id(:gpg_uid),
                _("GPG UID"),
                Ops.get_string(Support.options, "VAR_OPTION_GPG_UID", "")
              )
            )
          )
        ),
        Frame(
          _("Upload Information"),
          VBox(
            Left(
              InputField(
                Id(:target),
                _("Upload Target"),
                Builtins.deletechars(
                  Ops.get_string(
                    Support.options,
                    "VAR_OPTION_UPLOAD_TARGET",
                    ""
                  ),
                  "'"
                )
              )
            ),
            Left(
              InputField(
                Id(:novell_number),
                _("Service request number"),
                Support.novell_number
              )
            )
          )
        )
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "contact", ""),
        Label.BackButton,
        Label.NextButton
      )
      UI.ChangeWidget(:novell_number, :ValidChars, "0123456789")

      ret = nil
      while true
        ret = UI.UserInput

        # abort?
        if ret == :abort || ret == :cancel
          if ReallyAbort()
            break
          else
            next
          end
        elsif ret == :next || ret == :back
          Ops.set(
            Support.options,
            "VAR_OPTION_CONTACT_COMPANY",
            Convert.to_string(UI.QueryWidget(:company, :Value))
          )
          Ops.set(
            Support.options,
            "VAR_OPTION_CONTACT_EMAIL",
            Convert.to_string(UI.QueryWidget(:email, :Value))
          )
          Ops.set(
            Support.options,
            "VAR_OPTION_CONTACT_NAME",
            Convert.to_string(UI.QueryWidget(:name, :Value))
          )
          Ops.set(
            Support.options,
            "VAR_OPTION_CONTACT_PHONE",
            Convert.to_string(UI.QueryWidget(:phone, :Value))
          )
          Ops.set(
            Support.options,
            "VAR_OPTION_CONTACT_STOREID",
            Convert.to_string(UI.QueryWidget(:storeid, :Value))
          )
          Ops.set(
            Support.options,
            "VAR_OPTION_CONTACT_TERMINALID",
            Convert.to_string(UI.QueryWidget(:terminalid, :Value))
          )
          Ops.set(
            Support.options,
            "VAR_OPTION_UPLOAD_TARGET",
            Builtins.sformat(
              "'%1'",
              Convert.to_string(UI.QueryWidget(:target, :Value))
            )
          )
          Ops.set(
            Support.options,
            "VAR_OPTION_GPG_UID",
            Convert.to_string(UI.QueryWidget(:gpg_uid, :Value))
          )
          Support.novell_number = Convert.to_string(
            UI.QueryWidget(:novell_number, :Value)
          )
          if Ops.greater_than(Builtins.size(Support.novell_number), 0)
            if Builtins.size(Support.novell_number) < 11
              Popup.Error(_("The service request number must be at least 11 digits"))
              ret = nil
              next
            end
          end
          Support.WriteConfig
          break
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end

      deep_copy(ret)
    end


    def GenerateDialog
      caption = _("Collecting Data")
      contents = VBox(LogView(Id(:log), _("Progress"), 1000, 1000))
      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "collecting", ""),
        Label.BackButton,
        Label.NextButton
      )
      uuid_param = Builtins.issubstring(
        Ops.get_string(Support.options, "VAR_OPTION_UPLOAD_TARGET", ""),
        "novell.com"
      ) ? "-q" : ""
      cmd = Builtins.sformat(
        "supportconfig %1 %2 -t %3",
        Support.GetParameterList,
        uuid_param,
        Ops.get_string(Support.log_files, "tmp_dir", "")
      )
      if Support.WhoAmI != 0
        return :back if !Support.AskForRootPwd
        id = Support.WhoAmI
        SCR.Write(
          path(".target.string"),
          Support.pwd_file,
          Ops.add(Support.root_pw, "\n")
        )
        cmd = Builtins.sformat(
          "cat %4 | su -c '%1 && chown -R %3 %2'",
          cmd,
          Ops.get_string(Support.log_files, "tmp_dir", ""),
          id,
          Support.pwd_file
        )
      end
      ret = nil
      pid = Convert.to_integer(SCR.Execute(path(".process.start_shell"), cmd))
      unfinished_line = ""
      Wizard.DisableNextButton
      while true
        Builtins.sleep(100)
        if SCR.Read(path(".process.running"), pid) == true
          new_text = Convert.to_string(SCR.Read(path(".process.read"), pid))
          UI.ChangeWidget(Id(:log), :LastLine, new_text) if new_text != nil
        else
          Wizard.EnableNextButton
          break
        end
        ret = Convert.to_symbol(UI.PollInput)
        if ret == :back || ret == :abort
          SCR.Execute(path(".process.kill"), pid)
          break
        end
      end
      if Support.WhoAmI != 0
        SCR.Write(path(".target.string"), Support.pwd_file, "")
      end
      while ret != :back && ret != :abort && ret != :next
        ret = Convert.to_symbol(UI.UserInput)
      end
      ret
    end



    def FilesDialog
      caption = _("Collected Data Review")
      # FIXME use list of generated files, as well as directory prefix
      output = Convert.to_map(
        SCR.Execute(
          path(".target.bash_output"),
          Builtins.sformat(
            "ls -t %1|grep nts|head -n1|tr -d '\n'",
            Ops.get_string(Support.log_files, "tmp_dir", "")
          )
        )
      )
      Builtins.y2milestone("output %1", output)
      if Ops.get_integer(output, "exit", -1) != 0
        Popup.Error(Ops.get_string(output, "stderr", ""))
        return :back
      end
      Ops.set(
        Support.log_files,
        "log_dir",
        Ops.get_string(output, "stdout", "")
      )
      full_log_path = Builtins.sformat(
        "%1/%2/",
        Ops.get_string(Support.log_files, "tmp_dir", ""),
        Ops.get_string(Support.log_files, "log_dir", "")
      )
      output = Convert.to_map(
        SCR.Execute(
          path(".target.bash_output"),
          Builtins.sformat("ls %1", full_log_path)
        )
      )
      if Ops.get_integer(output, "exit", -1) != 0
        Popup.Error(Ops.get_string(output, "stderr", ""))
        return :back
      end
      files = Builtins.filter(
        Builtins.splitstring(Ops.get_string(output, "stdout", ""), "\n")
      ) { |s| Ops.greater_than(Builtins.size(s), 0) }
      contents = VBox(
        HBox(
          HStretch(),
          ReplacePoint(
            Id(:filelist_rp),
            ComboBox(
              Id(:filelist),
              Opt(:notify, :hstretch),
              _("File Name"),
              files
            )
          ),
          VBox(
            Label(""),
            PushButton(Id(:remove), Opt(:hstretch), _("Remove from Data"))
          ),
          HStretch()
        ),
        ReplacePoint(
          Id(:file_rp), #	`MultiLineEdit (`id (`file), `opt (`read_only), _("File Contents"))
          RichText(Id(:file), Opt(:plainText), "")
        )
      )
      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "review", ""),
        Label.BackButton,
        Label.NextButton
      )
      ret = :filelist
      while true
        if ret == :filelist
          file = Ops.add(
            full_log_path,
            Convert.to_string(UI.QueryWidget(Id(:filelist), :Value))
          )
          data = Convert.to_string(SCR.Read(path(".target.string"), file))
          UI.ReplaceWidget(
            Id(:file_rp),
            RichText(Id(:file), Opt(:plainText), data)
          ) 
        end
        ret = Convert.to_symbol(UI.UserInput)
        if ret == :next
          break
        end
        break if ret == :abort || ret == :back
        if ret == :remove
          file = Convert.to_string(UI.QueryWidget(Id(:filelist), :Value))
          files = Builtins.filter(files) { |f| f != file }
          UI.ReplaceWidget(
            Id(:filelist_rp),
            ComboBox(
              Id(:filelist),
              Opt(:notify, :hstretch),
              _("File Name"),
              files
            )
          )
          ret = :filelist
          # FIXME uncomment, following line not tested
          Builtins.y2milestone("removing %1%2", full_log_path, file)
          SCR.Execute(
            path(".target.bash"),
            Builtins.sformat("/bin/rm %1%2", full_log_path, file)
          )
        end
      end
      ret
    end
  end
end
