all: svndns.pdf svndns.png

svndns.pdf: svndns.graffle
	osascript OmniGraffleConverter.scpt \
		`pwd`/$< `pwd`/$@

svndns.png: svndns.graffle
	osascript OmniGraffleConverter.scpt \
		`pwd`/$< `pwd`/$@

clean:
	rm -f svndns.pdf svndns.png
