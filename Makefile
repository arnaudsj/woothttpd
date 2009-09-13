compile:
	erl -make
	
clean:
	rm -rf ./ebin/*.*

run:	compile
	erl -noshell -pa ./ebin -s nanohttpd start -s init stop

