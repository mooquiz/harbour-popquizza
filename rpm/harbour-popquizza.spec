Name:       harbour-popquizza
Summary:    Daily pop music quiz
Version:    1.0.6
Release:    1
License:    AGPLv3+
URL:        https://popquizza.com
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Native Sailfish OS client for popquizza.com — ten new pop music
questions every day. Questions are fetched from the web; scores,
streaks and history live on the device.

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5
%make_build

%install
%qmake5_install
# Harbour forbids /usr/share/licenses; ship the licence in the app dir
install -m 644 -p LICENSE %{buildroot}%{_datadir}/%{name}/LICENSE
desktop-file-install --delete-original \
  --dir %{buildroot}%{_datadir}/applications \
  %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
