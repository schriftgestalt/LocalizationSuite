all:	doc tests

tests:
	cd Resources/Test\ Data/Builder && make
	cd Resources/Test\ Data/Loader && make

doc:	
	cd Resources/Doc && make -j3

clean:
	cd Resources/Test\ Data/Builder && make clean
	cd Resources/Test\ Data/Loader && make clean
	cd Resources/Doc && make clean
