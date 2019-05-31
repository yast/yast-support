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

# File:	include/support/wizards.ycp
# Package:	Configuration of support
# Summary:	Wizards definitions
# Authors:	Michal Zugec <mzugec@novell.com>
#
# $Id: wizards.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module SupportWizardsInclude
    def initialize_support_wizards(include_target)
      Yast.import "UI"

      textdomain "support"

      Yast.import "Sequencer"
      Yast.import "Wizard"

      Yast.include include_target, "support/complex.rb"
      Yast.include include_target, "support/dialogs.rb"
    end

    # Main workflow of the support configuration
    # @return sequence result
    def MainSequence
      # FIXME: adapt to your needs
      aliases = {
        "overview"   => lambda { OverviewDialog() },
        "upload1"    => lambda { UploadDialog(false) },
        "upload2"    => lambda { UploadDialog(true) },
        "parameters" => lambda { ParametersDialog() },
        "expert"     => lambda { ExpertDialog() },
        "contact"    => lambda { ContactDialog() },
        "generate"   => lambda { GenerateDialog() },
        "files"      => lambda { FilesDialog() }
      }

      # FIXME: adapt to your needs
      sequence = {
        "ws_start"   => "overview",
        "overview"   => {
          :cancel  => :abort,
          :abort   => :abort,
          :back    => :back,
          :tarball => "parameters",
          :upload  => "upload1",
          :next    => :next
        },
        "upload1"    => {
          :cancel => :abort,
          :abort  => :abort,
          :back   => "overview",
          :next   => "overview"
        },
        "parameters" => {
          :cancel => :abort,
          :abort  => :abort,
          :expert => "expert",
          :next   => "contact"
        },
        "expert"     => {
          :cancel => :abort,
          :abort  => :abort,
          :back   => :back,
          :next   => "parameters"
        },
        "contact"    => {
          :cancel => :abort,
          :abort  => :abort,
          :back   => :back,
          :next   => "generate"
        },
        "generate"   => {
          :cancel => :abort,
          :abort  => :abort,
          :back   => :back,
          :next   => "files"
        },
        "files"      => {
          :cancel => :abort,
          :abort  => :abort,
          :back   => :back,
          :next   => "upload2"
        },
        "upload2"    => {
          :cancel => :abort,
          :abort  => :abort,
          :back   => "overview",
          :next   => "overview"
        }
      }

      ret = Sequencer.Run(aliases, sequence)

      deep_copy(ret)
    end

    # Whole configuration of support
    # @return sequence result
    def SupportSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainSequence() },
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :cancel => :abort, :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog
      Wizard.SetDesktopTitle("org.openSUSE.YaST.Support")

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end

    # Whole configuration of support but without reading and writing.
    # For use with autoinstallation.
    # @return sequence result
    def SupportAutoSequence
      # Initialization dialog caption
      caption = _("Support Configuration")
      # Initialization dialog contents
      contents = Label(_("Initializing..."))

      Wizard.CreateDialog
      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.NextButton
      )

      ret = MainSequence()

      UI.CloseDialog
      deep_copy(ret)
    end
  end
end
