#!/bin/bash

function build_mirror {
    local src_int=${1}
    local dst_int=${2}

    if [ $# -ne 2 ];then
        usage
        exit 1
    else
        echo "Creating Mirror: ${src_int} -> ${dst_int}"
    fi

    # Force the source port up
    ip link set ${src_int} up

    # Mirror the inbound traffic
    tc qdisc add dev ${src_int} ingress
    tc filter add dev ${src_int} parent ffff:    \
        protocol all                            \
        u32 match u8 0 0                        \
        action mirred egress mirror dev ${dst_int}

    # Mirror the outbound traffic
    tc qdisc add dev ${src_int} handle 1: root prio
    tc filter add dev ${src_int} parent 1:          \
        protocol all                                \
        u32 match u8 0 0                            \
        action mirred egress mirror dev ${dst_int}
}

function teardown_mirror {
    local src_int=${1}

    if [ $# -ne 1 ];then
        usage
        exit 1
    else
        echo "Destroying Mirror on ${src_int}"
    fi

    tc qdisc del dev ${src_int} ingress
    tc qdisc del dev ${src_int} root
}

function usage {
    cat << EOF
${UTIL}: Creates and destroys mirrors using traffic control
usage: ${UTIL} COMMAND [OPTIONS]

Commands:
    build SOURCE DESTINATION
        Mirrors the traffic from the SOURCE interface to
        the DESTINATION interface.
    teardown SOURCE
        Removes the traffic mirror on the SOURCE interface.

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