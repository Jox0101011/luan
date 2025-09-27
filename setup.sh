if [ -$EUID -ne 0 ]; then
    echo "use esse script com root seu bobão"
else
    cp man/luan.1 "/usr/local/share/man/man1/"
    mandb
    cp src/luan /bin/
fi

