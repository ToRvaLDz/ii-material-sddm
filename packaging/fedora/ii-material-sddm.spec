Name:           ii-material-sddm
Version:        1.0
Release:        1%{?dist}
Summary:        Material Design theme for the SDDM display manager
License:        GPL-3.0-or-later
URL:            https://github.com/ToRvaLDz/ii-material-sddm
Source0:        %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:      noarch

Requires:       sddm
Recommends:     qt6-qt5compat
Suggests:       acl

%description
ii-material-sddm is a clean Material Design theme for the SDDM display
manager. It features a customizable color scheme via colors.json, support
for Matugen integration, blur effects (requires qt6-qt5compat), and a set
of QML components for clock, user selector, session selector, password
field, toolbar, and virtual keyboard.

%prep
%autosetup

%build
# Nessuna compilazione necessaria — tema QML puro

%install
install -d %{buildroot}%{_datadir}/sddm/themes/%{name}
install -d %{buildroot}%{_datadir}/sddm/themes/%{name}/Components
install -d %{buildroot}%{_datadir}/sddm/themes/%{name}/Backgrounds

# File radice del tema
install -m 0644 Main.qml           %{buildroot}%{_datadir}/sddm/themes/%{name}/
install -m 0644 metadata.desktop   %{buildroot}%{_datadir}/sddm/themes/%{name}/
install -m 0644 theme.conf         %{buildroot}%{_datadir}/sddm/themes/%{name}/
install -m 0644 colors.json        %{buildroot}%{_datadir}/sddm/themes/%{name}/
install -m 0644 translations.js    %{buildroot}%{_datadir}/sddm/themes/%{name}/
install -m 0644 preview.png        %{buildroot}%{_datadir}/sddm/themes/%{name}/

# Componenti QML
install -m 0644 Components/Clock.qml           %{buildroot}%{_datadir}/sddm/themes/%{name}/Components/
install -m 0644 Components/PasswordField.qml   %{buildroot}%{_datadir}/sddm/themes/%{name}/Components/
install -m 0644 Components/SessionSelector.qml %{buildroot}%{_datadir}/sddm/themes/%{name}/Components/
install -m 0644 Components/Toolbar.qml         %{buildroot}%{_datadir}/sddm/themes/%{name}/Components/
install -m 0644 Components/ToolbarButton.qml   %{buildroot}%{_datadir}/sddm/themes/%{name}/Components/
install -m 0644 Components/UserSelector.qml    %{buildroot}%{_datadir}/sddm/themes/%{name}/Components/
install -m 0644 Components/VirtualKeyboard.qml %{buildroot}%{_datadir}/sddm/themes/%{name}/Components/

# Sfondo
install -m 0644 Backgrounds/default.jpg %{buildroot}%{_datadir}/sddm/themes/%{name}/Backgrounds/

%files
%license LICENSE
%dir %{_datadir}/sddm/themes/%{name}
%dir %{_datadir}/sddm/themes/%{name}/Components
%dir %{_datadir}/sddm/themes/%{name}/Backgrounds
%{_datadir}/sddm/themes/%{name}/Main.qml
%{_datadir}/sddm/themes/%{name}/metadata.desktop
%{_datadir}/sddm/themes/%{name}/theme.conf
%{_datadir}/sddm/themes/%{name}/colors.json
%{_datadir}/sddm/themes/%{name}/translations.js
%{_datadir}/sddm/themes/%{name}/preview.png
%{_datadir}/sddm/themes/%{name}/Components/Clock.qml
%{_datadir}/sddm/themes/%{name}/Components/PasswordField.qml
%{_datadir}/sddm/themes/%{name}/Components/SessionSelector.qml
%{_datadir}/sddm/themes/%{name}/Components/Toolbar.qml
%{_datadir}/sddm/themes/%{name}/Components/ToolbarButton.qml
%{_datadir}/sddm/themes/%{name}/Components/UserSelector.qml
%{_datadir}/sddm/themes/%{name}/Components/VirtualKeyboard.qml
%{_datadir}/sddm/themes/%{name}/Backgrounds/default.jpg

%changelog
* Tue Apr 08 2026 Marco Migozzi <marco@migozzi.it> - 1.0-1
- Rilascio iniziale del pacchetto Fedora
- Tema Material Design per SDDM con supporto Matugen
