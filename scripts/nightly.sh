#!/bin/sh

# nightly build script

eval "$(make print-LOGSDIR,PRODUCT_VERSION)"

for RECYCLE in $(cd ${LOGSDIR}; find . -name "[0-9]*" -type f | sort -r | tail -n +7); do
	(cd ${LOGSDIR}; rm ${RECYCLE})
done

(make clean-obj 2>&1) > /dev/null

mkdir -p ${LOGSDIR}/${PRODUCT_VERSION}

for STAGE in update info base kernel distfiles; do
	# we don't normally clean these stages
	(time make ${STAGE} 2>&1) > ${LOGSDIR}/${PRODUCT_VERSION}/${STAGE}.log
done

for FLAVOUR in OpenSSL; do
	if [ -z "${1}" ]; then
		(make clean-packages FLAVOUR=${FLAVOUR} 2>&1) > /dev/null
	fi
	for STAGE in ports plugins core test; do
		(time make ${STAGE} FLAVOUR=${FLAVOUR} 2>&1) \
		    > ${LOGSDIR}/${PRODUCT_VERSION}/${STAGE}-${FLAVOUR}.log
	done
done

tar -C ${LOGSDIR} -czf ${LOGSDIR}/${PRODUCT_VERSION}.tgz ${PRODUCT_VERSION}
rm -rf ${LOGSDIR}/latest
mv ${LOGSDIR}/${PRODUCT_VERSION} ${LOGSDIR}/latest
