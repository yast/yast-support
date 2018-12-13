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

# File:	include/support/complex.ycp
# Package:	Configuration of support
# Summary:	Dialogs definitions
# Authors:	Michal Zugec <mzugec@novell.com>
#
# $Id: complex.ycp 41350 2007-10-10 16:59:00Z dfiser $

require "shellwords"

module Yast
  module SupportComplexInclude
    def initialize_support_complex(include_target)
      Yast.import "UI"

      textdomain "support"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Confirm"
      Yast.import "Support"


      Yast.include include_target, "support/helps.rb"
    end

    # Return a modification status
    # @return true if data was modified
    def Modified
      Support.Modified
    end

    def ReallyAbort
      !Support.Modified || Popup.ReallyAbort(true)
    end

    def PollAbort
      UI.PollInput == :abort
    end

    # Read settings dialog
    # @return `abort if aborted and `next otherwise
    def ReadDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "read", ""))
      # Support::SetAbortFunction(PollAbort);
      #    if (!Confirm::MustBeRoot()) return `abort;
      if Support.WhoAmI != 0
        # use configuration file in home directory
        cmd = Builtins.sformat()
        out = SCR.Execute(path(".target.bash_output"), "/usr/bin/ls ~/.supportconfig")
        file = Ops.get_string(out, "stdout", "")
        file = Ops.get(Builtins.splitstring(file, "\n"), 0, "")
        return :abort if !Confirm.MustBeRoot if file == "" || file == nil
        Builtins.y2milestone("Using configuration file %1", file)
        Builtins.setenv("SC_CONF", file)
        # ensure ~/.supportconfig does exist
        if SCR.Read(path(".target.size"), file) < 0
          SCR.Execute(path(".target.bash"), "/usr/bin/cp /etc/supportconfig.conf #{file.shellescape}")
        end
        SCR.UnregisterAgent(path(".etc.supportconfig"))
        SCR.RegisterAgent(
          path(".etc.supportconfig"),
          term(
            :ag_ini,
            term(
              :IniAgent,
              file,
              {
                "options"  => [
                  "global_values",
                  "comments_last",
                  "line_can_continue",
                  "join_multiline"
                ],
                "comments" =>
                  # like above, but followed by non a-z nor blank nor '=' chars
                  [
                    "^[ \t]*$",
                    # empty line
                    "^[ \t]+[;#].*$",
                    # comment char is not first char
                    "^[#][ \t]*$",
                    # only comment chars
                    "^[#][ \t]*\\[[^]]*$",
                    # comment chars followed by '[' without matching ']'
                    "^[#][^ \t[]",
                    # comment char followed by non-blank nor '['
                    "^[#][ \t]+[^[a-z \t].*$",
                    # comment chars followed by non a-z char nor '[' nor blank
                    "^[#][ \t]+[a-z ]*[a-z][ \t]*$",
                    # comment chars followed by a-z or blank chars
                    "^[#][ \t]+[a-z ]*[a-z][ \t]*[^a-z \t=].*$"
                  ],
                #         "sections" : [
                #             $[
                #                 "begin" : [ "^[ \t]*\\[[ \t]*(.*[^ \t])[ \t]*\\][ \t]*", "[%s]" ],
                #             ], $[
                #                 // this is a special type for commenting out the values
                #                 "begin" : [ "^[#;][ \t]*\\[[ \t]*(.*[^ \t])[ \t]*\\][ \t]*", "# [%s]" ],
                #             ]
                #         ],
                # we need to exclude ; because of the second matching rule
                "params"   => [
                  # Options with one value ('yes' / 'no')
                  #                $[ "match" : [ "^[#;][ \t]*([^ \t]+)[ \t]+([^ \t]+)[ \t]+$", "%s %s" ]],
                  #                $[ "match" : [ "^[#;][ \t]*([^ \t\=]+)[ \t\=]?(.+)[ \t]*$", "; %s %s" ]],
                  # Options with more possible values
                  #                  $[ "match" :   [ "^[ \t]*([^ \t\=]+)[ \t\=]+[ ]*\"(.*)\"[ \t]*$", "%s=\"%s\"" ]],
                  # string
                  {
                    "match" => [
                      "^[ \t]*([^ \t=]+)[ \t=]+[ ]*\"(.*)\"[[:space:]]*#[-[:space:][:alnum:]]*$",
                      "%s=\"%s\""
                    ]
                  },
                  {
                    "match" => [
                      "^[ \t]*([^ \t=]+)[ \t=]+[ ]*\"(.*)\"[[:space:]]*$",
                      "%s=\"%s\""
                    ]
                  },
                  # number
                  {
                    "match" => [
                      "^[ \t]*([^ \t=]+)[ \t=]+[ ]*([[:digit:]]+)[[:space:]]*#[-[:alnum:][:space:]]*$",
                      "%s=%s"
                    ]
                  },
                  {
                    "match" => [
                      "^[ \t]*([^ \t=]+)[ \t=]+[ ]*(.+)[[:space:]]*$",
                      "%s=%s"
                    ]
                  }
                ]
              }
            )
          )
        )
      end
      Builtins.y2milestone(
        "Read 2: %1",
        SCR.Read(path(".etc.supportconfig.all"))
      )

      ret = Support.Read
      ret ? :next : :abort
    end

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      ret = Support.Write
      ret ? :next : :abort
    end
  end
end
