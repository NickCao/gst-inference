Name:           gst-shark
Version:        0.8.2
Release:        1%{?dist}
Summary:        GstShark is a front-end for GStreamer traces

License:        LGPL-2.1-only
URL:            https://github.com/RidgeRun/gst-shark
Source0:        https://github.com/RidgeRun/gst-shark/archive/refs/tags/v%{version}.tar.gz

BuildRequires:  meson
BuildRequires:  gcc
BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(gstreamer-1.0)
BuildRequires:  pkgconfig(gstreamer-base-1.0)
BuildRequires:  pkgconfig(libxml-2.0)
BuildRequires:  pkgconfig(gio-2.0)
BuildRequires:  pkgconfig(gstreamer-check-1.0)
BuildRequires:  pkgconfig(libgvc)

%package devel
Summary:        Development libraries and header files for %{name}
Requires:       %{name}%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}

%description
%{summary}.

%description devel
%{summary}.

%prep
%autosetup

%build
%meson
%meson_build

%install
%meson_install

%check
%meson_test

%files
%license COPYING
%{_libdir}/gstreamer-1.0/libgstsharktracers.so.*
%{_libdir}/libgstshark.so.*

%files devel
%{_libdir}/gstreamer-1.0/libgstsharktracers.a
%{_libdir}/gstreamer-1.0/libgstsharktracers.so
%{_libdir}/libgstshark.a
%{_libdir}/libgstshark.so

%changelog
* Thu Aug 07 2025 Super User
-
