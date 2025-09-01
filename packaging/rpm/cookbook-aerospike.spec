Name: cookbook-aerospike
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: cookbook to install and configure aerospike in the redborder platform.

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-aerospike
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/aerospike
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/aerospike
chmod -R 0755 %{buildroot}/var/chef/cookbooks/aerospike
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/aerospike/README.md

%pre
if [ -d /var/chef/cookbooks/aerospike ]; then
    rm -rf /var/chef/cookbooks/aerospike
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload aerospike'
  ;;
esac

%postun
# Deletes directory when uninstalling the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/aerospike ]; then
  rm -rf /var/chef/cookbooks/aerospike
fi

%files
%defattr(0644,root,root)
%attr(0755,root,root)
/var/chef/cookbooks/aerospike
%defattr(0644,root,root)
/var/chef/cookbooks/aerospike/README.md

%doc

%changelog
* Wed Aug 06 2025 Daniel Castro <dcastro@redborder.com>
- Create aerospike cookbook
