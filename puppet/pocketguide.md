Pocket Guide to Managing Windows via Puppet
===========================================
by RIS$


Managing Windows via puppet introduces a whole new way of thinking about system resource management.
This document will review  effectively managing windows systems.
It is not meant to be a replacement or substitute for puppet documentation or man pages but instead
be a starting point for resource management.

Additional References
=====================

PuppetLabs has a document on Windows manifests [here](http://docs.puppetlabs.com/windows/writing.html)

This is the Comprehensive Type Reference (version 2.7x):
http://docs.puppetlabs.com/references/2.7.stable/type.html


File Resource
=============
Q: How do I deploy a file.

A: File Resource of course!

Here is an example:

```puppet
file {'my-filename.ps1':
  ensure   => present,
  path     => 'C:/somepath/my-filename.ps1', # watch your slashes and double them for escaping if double quoting backslashes
  source   => "puppet:///modules/${module_name}/my-filename.ps1",
}
```

* Do not specify mode. Do not specify owner.  If you have permissioning requirements
these need to be handled via an exec resource using Set-ACL, subinacl, cacls, or similar utility.
* Footnote: Modes are not enforced by default because we [patched](https://github.com/rismoney/forthewin/blob/master/puppet/source.rb.patch) puppet enterprise
* An ACL provider is being built. https://tickets.puppetlabs.com/browse/PUP-1458

Package Resource
================
Q: How do I deploy a package.

A: The package resource of course!  I use the chocolatey almost exclusively for package deployment.  While it is possible to use MSI natively
the preferred approach is using our chocolatey repo and package manager:

Here is an example:
```puppet
package {'acrobat':
  ensure            => present,  # this could be version number, latest, etc.
  install_options   => '-pre'    # specify additional choco options.  (optional)
}
```

Note: Provider parameter specification is not necessary because we have the following in site.pp

```puppet
Package { provider => chocolatey }
```

Exec Resource
=============
Q: How do I run a script or application that does something.

A: The Exec Resource.


2 approaches can be used.

1. One is natively exec
1. powershell provider.

Note the difference with the provider parameter below

Here is an example of extracting a zip file using native exec.  If no provider is specified, the commands will execute within cmd.exe

```puppet
exec { 'Extract-myarchive.zip':
  command   => 'X:\tools\7za.exe x -y "-oC:\" c:\zips\myarchive.zip "-aos"',
  require   => Exec['myarchive'],
}
```

With a powershell provider, you need not run powershell.exe.  This allows you to run cmdlets or powershell scripts
natively on the command paremeter. Here is an example of powershell exec provider.

```puppet
exec { "myscript.ps1":
  command   => "C:/scripts/myscript.ps1",
  provider  => powershell,
  logoutput => true, # useful if you want to see output in the debug log
  require   => File['myscript.ps1.ps1'], # needs to rely on file resource
  unless    => "C:/scripts/checker.ps1",  # important on execs to be idempotent.
}
```

Note we have the system path in the Exec by default in site.pp.  specifically:

```puppet
Exec { path => $::path }
```


Registry Resource
================
Q: How do I deploy a registry setting.

A: I use the registry provider.

More information can be found [here](https://github.com/puppetlabs/puppetlabs-registryhttps://github.com/puppetlabs/puppetlabs-registry):

Here is an example:
```puppet
registry_value { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\browser\Parameters\MaintainServerList':
  ensure         => present,
  type           => string,
  data           => 'Yes',
}
```

DISM Resource
=============
Q: How do I deploy a Feature or Role.

A: I leverage the [DISM Puppet Module](https://github.com/puppetlabs/puppetlabs-dism)

Example:
```puppet
dism { 'NetFx3':
  ensure => present,
}
```

DNS Records
===========
Q: How do I manage zones and records in DNS

A: The [provider](https://github.com/rismoney/puppet-windns) available.


Here is an example, along with the commit referenced above this:

```puppet
dnsrecord {'wksa-mss0022.fubar.com.':
  ensure => present,
  value  => '172.21.5.179',
  type   => 'A',
  zone   => 'fubar.com.',
  ttl    => 12001,
  server => 'cc-ad01',
  require => Dnszone['fubar.com'];
}
```

Network
=======
Q: How do I manage Windows IP stack?

A: We use the [network provider](https://github.com/rismoney/puppet-windowsnetwork):

```puppet
ipconfig {'Local Area Connection':
  ensure                      => present,
  ipaddress                   => ["10.10.10.100"],
  subnetmask                  => ["255.255.255.0"],
  defaultgateway              => ["10.10.10.1"],
  gwcostmetric                =>  256,
  dnsregister                 => true,
  fulldnsregister             => true,
  netbios                     => 'enabled',
  dns                         => ['8.8.8.8','8.8.4.4'],
  dnsdomainsuffixsearchorder  => ['example.com','example2.com'],
  dnsdomain                   => 'example.com'
}
```

Coming Soon to this document
==================
[WSUS Provider] (https://github.com/rismoney/puppet-wsus)

[Clustering] (https://github.com/rismoney/puppet-winclusters)

[Windows-Path] (https://github.com/basti1302/puppet-windows-path)

Windows Firewall

Citrix

Baremetal

IIS

AD

etc.
etc.
etc.

