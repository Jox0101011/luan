#!/usr/bin/bash
set -u

if [[ -f /usr/bin/sudo ]]; then
    root="sudo"
elif [[ -f /usr/bin/doas ]]; then
    root="doas"
else
    root="undefined"
fi

verify_man()
{
    if [[ -f /usr/bin/man ]]; then
        printf "/usr/bin/man: OK [Exists]"
        echo
    else
        printf "/usr/bin/man: ... [Not Exists]"
        echo
        echo "Install mandoc or mandb (recommended: mandoc)"
    fi
}

check_root()
{
    if [[ $EUID -ne 0 ]]; then
        echo "Root: ... [Dead]"
        if [[ "$root" == "undefined" ]]; then
            echo "Please run this script as root (no sudo or doas found on this system)"
        else
            echo "Please use $root with this script"
        fi
        exit 1
    fi
    echo "Root: OK [$root]"
}

do_install()
{
    check_root
    verify_man

    cp "man/luan.1" "/usr/local/share/man/man1/" \
        && echo "/usr/local/share/man/man1/luan.1: OK [Installed]" \
        || echo "/usr/local/share/man/man1/luan.1: ... [Failed]"

    if mandb 1>/dev/null; then
        echo "/usr/bin/mandb: OK [Updated]"
    else
        echo "/usr/bin/mandb: ... [Failed]"
    fi

    cp src/luan /usr/bin/ \
        && chmod +x /usr/bin/luan \
        && echo "/usr/bin/luan: OK [Installed]" \
        || echo "/usr/bin/luan: ... [Failed]"
}

do_uninstall()
{
    check_root
    verify_man

    if [[ -f "/usr/bin/luan" ]]; then
        echo "/usr/bin/luan: rm -f urself [Remove]"
        rm -f "/usr/bin/luan" \
            && echo "/usr/bin/luan: rm -f urself [Sucessfull]" \
            || echo "/usr/bin/luan: rm -f urself [Failed]"
    else
        echo "/usr/bin/luan: ... [Not Installed]"
    fi

    if [[ -f "/usr/local/share/man/man1/luan.1" ]]; then
        echo "/usr/local/share/man/man1/luan.1: rm -f urself [Remove]"
        rm -f "/usr/local/share/man/man1/luan.1" \
            && echo "/usr/local/share/man/man1/luan.1: rm -f urself [Sucess]" \
            || echo "/usr/local/share/man/man1/luan.1: rm -f urself [Failed]"
    else
        echo "/usr/local/share/man/man1/luan.1: ... [Not Installed]"
    fi
}

case "${1:-}" in
    --unistall|--uninstall)
        do_uninstall
        ;;
    "")
        do_install
        ;;
    *)
        echo "Unknown argument: $1"
        echo "Usage: $0 [--uninstall]"
        exit 1
        ;;
esac
