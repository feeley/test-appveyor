all:
	echo "abc" | sed -e "s/b/XXX/g"
	$(CC) -o foo.exe foo.c
