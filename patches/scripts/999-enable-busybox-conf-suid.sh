
set | grep -E "^FREETZ_BUSYBOX.*FEATURE_SUID_CONFIG=y$" || return 0

echo1 "creating /etc/busybox.conf"
cat >"${FILESYSTEM_MOD_DIR}/etc/busybox.conf" <<'_EOF'
#	Allow the SUID/SGID state of an applet to be determined at runtime
#	by checking /etc/busybox.conf. (This is sort of a poor man's sudo.)
#	The format of this file is as follows:
#
#	APPLET = [Ssx-][Ssx-][x-] [USER.GROUP]
#
#	s: USER or GROUP is allowed to execute APPLET.
#	   APPLET will run under USER or GROUP
#	   (regardless of who's running it).
#	S: USER or GROUP is NOT allowed to execute APPLET.
#	   APPLET will run under USER or GROUP.
#	   This option is not very sensical.
#	x: USER/GROUP/others are allowed to execute APPLET.
#	   No UID/GID change will be done when it is run.
#	-: USER/GROUP/others are not allowed to execute APPLET.
#
#	An example might help:
#
#	|[SUID]
#	|su = ssx root.0 # applet su can be run by anyone and runs with
#	|                # euid=0,egid=0
#	|su = ssx        # exactly the same
#	|
#	|mount = sx- root.disk # applet mount can be run by root and members
#	|                      # of group disk (but not anyone else)
#	|                      # and runs with euid=0 (egid is not changed)
#	|
#	|cp = --- # disable applet cp for everyone
#
#	The file has to be owned by user root, group root and has to be
#	writeable only by root:
#		(chown 0.0 /etc/busybox.conf; chmod 600 /etc/busybox.conf)
#	The busybox executable has to be owned by user root, group
#	root and has to be setuid root for this to work:
#		(chown 0.0 /bin/busybox; chmod 4755 /bin/busybox)
#
#	Robert 'sandman' Griebl has more information here:
#	<url: http://www.softforge.de/bb/suid.html >.
#
[SUID]
su = ss- root.root	# applet su can be run by root and members
			# of group root (but not anyone else)
			# and runs with euid=0 (egid is not changed)
_EOF

#chown 0.0 "${FILESYSTEM_MOD_DIR}/etc/busybox.conf" 
chmod 600 "${FILESYSTEM_MOD_DIR}/etc/busybox.conf" 

echo1 "setting suid on /bin/busybox"
#chown 0.0 "${FILESYSTEM_MOD_DIR}/bin/busybox"
chmod 4755 "${FILESYSTEM_MOD_DIR}/bin/busybox"
chmod 4755 "${PACKAGES_DIR}/busybox/busybox"

