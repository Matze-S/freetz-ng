[ "$FREETZ_PLCD_PATCH" == "y" ] || return 0

# MSCmod: QUICK HACK TO FIX PLCD LOCALE PROBS

if test -x "${FILESYSTEM_MOD_DIR}/sbin/plcd"; then

	echo1 'fixing plcd start without locale'

	mv -v "${FILESYSTEM_MOD_DIR}/sbin/plcd" "${FILESYSTEM_MOD_DIR}/sbin/plcd-avm"

	cat >"${FILESYSTEM_MOD_DIR}/sbin/plcd" <<'__EOF'
#!/bin/sh
unset LANG LC_ALL
export LANG LC_ALL
exec ${0}-avm "${*}"
__EOF

	chmod +x "${FILESYSTEM_MOD_DIR}/sbin/plcd"

fi

