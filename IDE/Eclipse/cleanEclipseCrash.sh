#!/bin/bash
clear
export ECLIPSE_METADATA=${WORKSPACE_HOME}/.metadata
echo
echo "Removing ${ECLIPSE_METADATA}/.lock"
rm -rf ${ECLIPSE_METADATA}/.lock
ls -la ${ECLIPSE_METADATA}/.lock
echo
echo
echo "Removing ${ECLIPSE_METADATA}/.plugins/org.eclipse.core.resources/.snap"
rm -rf ${ECLIPSE_METADATAE}/.plugins/org.eclipse.core.resources/.snap
ls -la ${ECLIPSE_METADATAE}/.plugins/org.eclipse.core.resources/.snap
echo 
