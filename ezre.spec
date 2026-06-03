%global source_date_epoch_from_changelog 0

Name: ps5mfr
Version: v1.0
Summary: Run make_fself.py recursively on a decrypted PS5 game dump folder.
Release: 1
License: BSD-3-Clause
URL: https://github.com/alex-free/ps5-make-fself-recursive
Packager: Alex Free

%description
Run make_fself.py recursively on a decrypted PS5 game dump folder.

%install
mkdir -p %{buildroot}/usr/bin
cp %{_sourcedir}/ps5mfr %{buildroot}/usr/bin/
cp %{_sourcedir}/make_fself.py %{buildroot}/usr/bin/

%files
/usr/bin/ps5mfr
/usr/bin/make_fself.py
