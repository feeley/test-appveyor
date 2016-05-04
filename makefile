all:
	echo "abc" | sed -e "s/b/XXX/g"
	which $(CC)
	$(CC) -v
	$(CC) -o foo.exe foo.c
