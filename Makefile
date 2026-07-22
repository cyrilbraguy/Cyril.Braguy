pdf:
    pandoc cv/cyril_braguy.md \
        --from markdown \
        --template cv/styles/resume.tex \
        --pdf-engine=xelatex \
        -o cv/output/cv.pdf

html:
    pandoc cv/cyril_braguy.md \
        --css cv/styles/resume.css \
        -o cv/output/cv.html
