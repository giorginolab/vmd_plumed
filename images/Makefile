FILES= help_page.png help_popup.png main.png native.png rama.png reference.png templates.png

# For the submission
default:
	cd ..; \
	for i in $(FILES); do \
		convert -compress ZIP images/$$i eps3:`basename $$i .png`.eps; done; \
	rm -f images.zip; \
	zip images.zip *.eps

PDF:
	cd ..; \
	for i in $(FILES); do \
		convert -compress ZIP images/$$i `basename $$i .png`.pdf; done; \
	rm -f images.zip; \
	zip images.zip $(FILES:.png=.pdf)

