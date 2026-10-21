@echo off
rem Startup script deployed by Group Policy (Computer Configuration > Policies >
rem Windows Settings > Scripts > Startup) and stored in the NETLOGON share,
rem so that every client of the domain can read it.
rem It maps the shared folder "Epfc" of the Active Directory server as drive Z:.
rem <ad-server> stands for the name of the Active Directory server.

net use Z: \\<ad-server>\Epfc
