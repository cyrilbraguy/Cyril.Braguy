.PHONY: all pdf html docx clean

all: pdf html docx

pdf:
	pandoc resume.md -o dist/resume.pdf \
		--template=templates/resume.latex \
		--lua-filter=templates/split-sidebar.lua \
		--pdf-engine=xelatex

html:
	pandoc resume.md -o dist/resume.html \
		--template=templates/resume.html.template \
		--lua-filter=templates/split-sidebar.lua
	cp templates/resume.css dist/resume.css
	cp -r images dist/images

docx:
	pandoc resume.md -o dist/resume.docx

clean:
	rm -rf dist/*
