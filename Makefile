HI = $(wildcard shaders/*.shader)

uncrustify:
	uncrustify -c uncrustify.conf \
		--replace --if-changed --no-backup \
		-q \
		shaders/*.shader
