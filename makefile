all:
	echo "abc" | sed -e "s/b/XXX/g"
	echo $(CC)
	$(CC) -o foo.exe foo.c
