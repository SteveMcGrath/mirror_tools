#!/bin/bash

function build_mirror {
    local ovs_bridge=${1}
    local ovs_src=${2}
    local ovs_dst=${3}
    local ovs_mirror=${4:-$2_$3_m0}

    if [ $# -lt 3 ];then
        usage
        exit 1
    fi

    ovs-vsctl -- set Bridge ${ovs_bridge} mirrors=@m \
        -- --id=@s get Port ${ovs_src} \
        -- --id=@d get Port ${ovs_dst} \
        -- --id=@m create Mirror name=${ovs_mirror} select-src-port=@s select-dst-port=@s output-port=@d select_all=1

    echo ${ovs_mirror}
}   

function teardown_mirror {
    local ovs_bridge=${1}
    local ovs_mirror=${2}

    if [ $# -neq 2 ];then
        usage
        exit 1
    fi

    ovs-vsctl -- --id=@m get mirror ${ovs_mirror} \
        -- remove Bridge ${ovs_bridge} mirrors @m
}

function usage {
    cat << EOF
${UTIL}: Creates and destroys mirrors for Open vSwitch.
usage: ${UTIL} COMMAND [OPTIONS]

Commands:
    build BRIDGE MIRROR_SOURCE MIRROR_DEST
                Creates a new mirror mirroring the source port to the destination port
    teardown BRIDGE MIRROR
                Destroys the mirror on the specified bridge
EOF
}

UTIL=$(basename $0)

if [ $# -eq 0 ]; then
    usage
    exit 0
fi

case ${1} in
    "build")
        shift
        build_mirror $@
        exit 0
        ;;
    "teardown")
        shift
        teardown_mirror $@
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo >&2 "${UTIL}: unknown command \"${1}\" (use --help for help)"
        exit 1
        ;;
esac