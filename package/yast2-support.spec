#
# spec file for package yast2-support
#
# Copyright (c) 2013 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-support
Version:        3.1.7
Release:        0

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2
url:            http://github.com/yast/yast-support

Group:	        System/YaST
License:        GPL-2.0
Requires:	yast2
BuildRequires:	yast2
BuildRequires:  yast2-devtools >= 3.0.6
BuildRequires:  rubygem(yast-rake)

BuildArch:	noarch

# Yast::CoreExt::AnsiString
Requires:       yast2-ruby-bindings >= 3.1.36

Summary:	YaST2 - Support Inquiries

%description
This module allows you to collect system information for installation
support in a standardized format.

%prep
%setup -n %{name}-%{version}

%check
rake test:unit

%build

%install
rake install DESTDIR="%{buildroot}"


%files
%defattr(-,root,root)
%dir %{yast_yncludedir}/support
%{yast_yncludedir}/support/*
%{yast_clientdir}/support.rb
%{yast_clientdir}/support_*.rb
%{yast_moduledir}/Support.*
%{yast_desktopdir}/support.desktop
%{yast_scrconfdir}/*.scr
%doc %{yast_docdir}
