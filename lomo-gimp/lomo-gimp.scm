;; $Id: lomo-gimp.scm,v 1.1 2008/07/28 14:05:30 ivalladolidt Exp $

;; Copyright (C) 2008 Ismael Valladolid Torres <ivalladt@gmail.com>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the HESSLA as published by
;; Hacktivismo. HESSLA is basically GPL with some political and
;; ethical restrictions. See the file COPYING or the URL below for
;; details.

;; http://www.hacktivismo.com/about/hessla.php

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; HESSLA for more details.

;; Lomo-Gimp is a script-fu for the GIMP that tries to enrich pictures
;; taken using a digital camera with the warmth of those taken with a
;; classic analog camera. Particularly enhances contrast, saturates
;; colors and applies random bright and dark overlays in form of a
;; slighty wrong exposition. The result would pretend to seem like the
;; one using an old rangefinder --Rollei, Petri or any of those today
;; very popular Lomo--. To be taken into account that the script-fu
;; does nothing to emulate the peculiar cromatic aberration in
;; pictures taken using those last.

;; Check http://lomo-gimp.berlios.de/ for more information.

(define (script-fu-lomo-gimp img
			     drawable
			     contrast
			     saturation
			     bright-opacity
			     shadow-opacity
			     duplicate-shadow
			     flatten
			     copy)

  (let* ((image (if (= copy TRUE)
		  (car (gimp-image-duplicate img))
		  img)))

    (gimp-image-undo-group-start image)

    (let* ((layer (car (gimp-image-flatten image)))
	 
	   (image-width (car (gimp-image-width image)))
	   (image-height (car (gimp-image-height image)))
	 
	   (half-image-width (/ image-width 2))
	   (half-image-height (/ image-height 2))
	 
	   (width-factor (/ (- 85 (rand 170)) 100))
	   (height-factor (/ (- 85 (rand 170)) 100))
	 
	   (center-x (+ half-image-width (* half-image-width width-factor)))
	   (center-y (+ half-image-height (* half-image-height height-factor))))

  (gimp-brightness-contrast layer 0 contrast)
  (gimp-hue-saturation layer 0 0 0 saturation)

  (let* ((bright-layer (car (gimp-layer-new image
					    image-width
					    image-height
					    1 "Brillo" bright-opacity 5))))

  (gimp-image-add-layer image bright-layer 0)
  (gimp-edit-clear bright-layer)
  (gimp-context-set-foreground '(255 255 255))

  (gimp-edit-blend bright-layer 2 0 2 100 0 0 FALSE FALSE 0 0 TRUE
		   center-x center-y
		   (+ half-image-width center-x) 0)

  (let* ((shadow-layer (car (gimp-layer-new image
					    image-width
					    image-height
					    1 "Sombra" shadow-opacity 5))))
  
  (gimp-image-add-layer image shadow-layer 0)
  (gimp-edit-clear shadow-layer)
  (gimp-palette-set-foreground '(0 0 0))

  (if (= (rand 2) 0)
      (begin
	(gimp-edit-blend shadow-layer 2 0 0 100 0 0 FALSE FALSE 0 0 TRUE
			 0 0
			 center-x center-y)
	
	(gimp-edit-blend shadow-layer 2 0 0 100 0 0 FALSE FALSE 0 0 TRUE
			 image-width image-height
			 center-x center-y))
      (begin
	(gimp-edit-blend shadow-layer 2 0 0 100 0 0 FALSE FALSE 0 0 TRUE
			 image-width 0
			 center-x center-y)
	
	(gimp-edit-blend shadow-layer 2 0 0 100 0 0 FALSE FALSE 0 0 TRUE
			 0 image-height
			 center-x center-y)))
  
  (cond ((= duplicate-shadow TRUE)
	 (let* ((shadow-layer2 (car (gimp-layer-copy shadow-layer 0)))
	 (gimp-image-add-layer image shadow-layer2 0)))))
  
  (cond ((= flatten TRUE)
	 (gimp-image-flatten image)))

  (cond ((= copy TRUE)
	 (gimp-display-new image)))

  (gimp-image-undo-group-end image)
  (gimp-displays-flush))))))


(script-fu-register "script-fu-lomo-gimp"
		    "Lomo-Gimp..."
		    "A simple analog camera faking effect"
		    "Ismael Valladolid Torres <ivalladt@gmail.com>"
		    "Ismael Valladolid Torres"
		    "2005"
		    "RGB*"
		    SF-IMAGE "The image" 0
		    SF-DRAWABLE "The layer" 0
		    SF-ADJUSTMENT "Contrast" '(20 0 60 1 5 0 0)
		    SF-ADJUSTMENT "Saturation" '(20 0 60 1 5 0 0)
		    SF-ADJUSTMENT "Bright layer opacity" '(80 0 100 1 10 0 0)
		    SF-ADJUSTMENT "Shadow layer opacity" '(100 0 100 1 10 0 0)
		    SF-TOGGLE "Duplicate the shadow layer" TRUE
		    SF-TOGGLE "Flatten image after processing" TRUE
		    SF-TOGGLE "Work on copy" TRUE)

(script-fu-menu-register "script-fu-lomo-gimp"
			 "<Image>/Script-Fu/Alchemy")
