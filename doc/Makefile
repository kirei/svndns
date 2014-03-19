all: svndns.pdf

svndns.pdf: svndns.graffle
	osascript OmniGraffleConverter.scpt \
		`pwd`/svndns.graffle `pwd`/svndns.pdf

clean:
	rm -f svndns.pdf
