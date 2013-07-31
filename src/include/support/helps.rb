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

# File:	include/support/helps.ycp
# Package:	Configuration of support
# Summary:	Help texts of all the dialogs
# Authors:	Michal Zugec <mzugec@novell.com>
#
# $Id: helps.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module SupportHelpsInclude
    def initialize_support_helps(include_target)
      textdomain "support"

      # All helps are here
      @HELPS = {
        # Read dialog help 1/2
        "read"           => _(
          "<p><b><big>Initializing Support Configuration</big></b><br>\n</p>\n"
        ) +
          # Read dialog help 2/2
          _(
            "<p><b><big>Aborting Initialization:</big></b><br>\nSafely abort the configuration utility by pressing <b>Abort</b> now.</p>\n"
          ),
        # Write dialog help 1/2
        "write"          => _(
          "<p><b><big>Saving Support Configuration</big></b><br>\n</p>\n"
        ) +
          # Write dialog help 2/2
          _(
            "<p><b><big>Aborting Saving:</big></b><br>\n" +
              "Abort the save procedure by pressing <b>Abort</b>.\n" +
              "An additional dialog informs whether it is safe to do so.\n" +
              "</p>\n"
          ),
        # Summary dialog help 1/3
        "summary"        => _(
          "<p><b><big>Support Configuration</big></b><br>\nConfigure support here.<br></p>\n"
        ) +
          # Summary dialog help 2/3
          _(
            "<p><b><big>Adding a support:</big></b><br>\n" +
              "Choose a support from the list of detected supports.\n" +
              "If your support was not detected, use <b>Other (not detected)</b>.\n" +
              "Then press <b>Configure</b>.</p>\n"
          ) +
          # Summary dialog help 3/3
          _(
            "<p><b><big>Editing or Deleting:</big></b><br>\n" +
              "If you press <b>Edit</b>, an additional dialog in which to change\n" +
              "the configuration opens.</p>\n"
          ),
        # Ovreview dialog help 1/3
        "overview"       => _(
          "\n" +
            "<p><b><big>Opening Novell Support Center</big></b><br>\n" +
            "To start a Web browser that opens the Novell Support Center Portal, use <b>Open Novell Support Center</b>.\n" +
            "You can then open a Service Request with Novell Technical Support. Make sure you write down\n" +
            "the Service Request number to include in the supportconfig data upload.</p>\n"
        ) +
          # Ovreview dialog help 2/3
          _(
            "<p><b><big>Collecting Data</big></b><br>\nTo run the supportconfig data collection tool, use <b>Collect Data</b></p>"
          ) +
          # Ovreview dialog help 3/3
          _(
            "<p><b><big>Uploading Collected Data</big></b><br>\n" +
              "To upload the data already collected to a server, use <b>Upload Data</b>.\n" +
              "The server may or may not be Novell Technical Support.</p>"
          ),
        # Configure1 dialog help 1/3
        "support_params" => _(
          "<p><b><big>Supportconfig Options</big></b><br>\n" +
            "Select an option to override the defaults. You can use the default settings,\n" +
            "gather the most data or only gather a minimum amount of data."
        ) +
          # Configure1 dialog help 2/3
          _(
            "<p><b><big>Expert Settings</big></b><br>\n" +
              "Select <b>Use Custom</b> and click the <b>Expert Settings</b> button\n" +
              "to select specific data sets to collect.</p>\n"
          ) +
          # Configure1 dialog help 3/3
          _(
            "<p><b><big>Options</big></b><br>\n" +
              "Collect additional information. Usually these options are not\n" +
              "necessary, but can be included if circumstances require more information.</p>\n"
          ),
        # Expert dialog help 1/1
        "expert_params"  => _(
          "<p><big><b>Default Options</b></big><br>\nSelect or deselect each of the data sets you would like to include in the supportconfig tarball.</p>"
        ),
        # Contact dialog help 1/4
        "contact"        => _(
          "<p><big><b>Contact Information</b></big><br>\n" +
            "Fill in each of the contact information fields that you would like to include\n" +
            "in the supportconfig tarball. The fields are saved in the basic-environment.txt file.</p>"
        ) +
          # Contact dialog help 2/4
          _(
            "<p><b><big>Upload Information</big></b><br>\n" +
              "The upload target is the supportconfig tarball's destination URI. Supported upload services include\n" +
              "ftp, http, https, scp. If you need to include the supportconfig tarball filename in your upload target,\n" +
              "use the <i>tarball</i> keyword. This will get replaced with the actual tarball filename.\n" +
              "See <i>man supportconfig(1)</i> for further details.</p>"
          ) +
          # Contact dialog help 3/4
          _(
            "<p><b><big>Upload Target Examples</big></b><br>\n" +
              "https://secure-www.novell.com/upload?appname=supportconfig&file=<i>tarball</i><br>\n" +
              "ftp://ftp.novell.com/incoming<br>\n" +
              "scp://central.server.foo.com/supportconfig/archives</p>"
          ) +
          # Contact dialog help 4/4
          _(
            "<p><b>Note:</b> If you are uploading a supportconfig tarball to Novell Technical Support,\nmake sure you include the Novell 11-digit service request number from your open service request.\n"
          ),
        # Collecting data dialkog help 1/1
        "collecting"     => _(
          "<p><b><big>Collecting Data</big></b>><br>\nData is being collected.</p>\n"
        ),
        # Data review dialog help 1/1
        "review"         => _(
          "<p><b><big>Collected Data Review</big></b><br>\n" +
            "Review the data collected by supportconfig. If you do not want to share some of the collected data,\n" +
            "use <b>Remove from Data</b> and the selected file will be removed.</p>\n"
        ),
        # Configure1 dialog help 1/3
        "upload_save"    => Ops.add(
          _(
            "<p><b><big>Upload supportconfig tarball to Novell Technical Support</big></b><br>\n" +
              "If you want to store a copy of the supportconfig tarball, select the target\n" +
              "directory and make sure that this option is checked.\n" +
              "<br></p>\n"
          ) +
            # Configure1 dialog help 2/3
            _(
              "<p><b><big>Upload URL</big></b><br>\n" +
                "This option has the location to which the supportconfig tarball will be uploaded\n" +
                "as default value.\n" +
                "Change this value only in special cases.\n" +
                "</p>\n"
            ),
          # Configure1 dialog help 3/3, %1 is a URL
          Builtins.sformat(
            _(
              "<p><b><big>Privacy Policy</big></b><br>\n" +
                "Find Novell's privacy policy at\n" +
                "<i>%1</i>.</p>\n"
            ),
            "http://www.novell.com/company/policies/privacy/"
          )
        ),
        "upload_select"  => Ops.add(
          _(
            "<p><b><big>Upload supportconfig tarball to Novell Technical Support</big></b><br>\n" +
              "If you have already created the supportconfig tarball, write the full path\n" +
              "into the <i>Package with log files</i> field.\n" +
              "<br></p>\n"
          ) +
            # Configure1 dialog help 2/3
            _(
              "<p><b><big>Upload URL</big></b><br>\n" +
                "This option has the location to which the supportconfig tarball will be uploaded\n" +
                "as default value.\n" +
                "Change this value only in special cases.\n" +
                "</p>\n"
            ),
          # Configure1 dialog help 3/3
          Builtins.sformat(
            _(
              "<p><b><big>Privacy Policy</big></b><br>\n" +
                "Find Novell's privacy policy at\n" +
                "<i>%1</i>.</p>\n"
            ),
            "http://www.novell.com/company/policies/privacy/"
          )
        ),
        # Configure2 dialog help 1/2
        "c2"             => _(
          "<p><b><big>Configuration Part Two</big></b><br>\n" +
            "Press <b>Next</b> to continue.\n" +
            "<br></p>\n"
        ) +
          # Configure2 dialog help 2/2
          _(
            "<p><b><big>Selecting Something</big></b><br>\n" +
              "It is not possible. You must code it first. :-)\n" +
              "</p>"
          )
      } 

      # EOF
    end
  end
end
