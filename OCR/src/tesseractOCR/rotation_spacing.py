# -*- coding: utf-8 -*-
"""
Automatically detect rotation and line spacing of an image of text using
Radon transform

If image is rotated by the inverse of the output, the lines will be
horizontal (though they may be upside-down depending on the original image)

It doesn't work with black borders
"""

from __future__ import division, print_function
from skimage.transform import radon
from PIL import Image
from numpy import asarray, mean, array, blackman
import numpy
from numpy.fft import rfft
import matplotlib.pyplot as plt
from matplotlib.mlab import rms_flat

import sys
import getopt

def main(argv):
	filename = ''
	try:
	  opts, args = getopt.getopt(argv,"hf:",["file="])
	except getopt.GetoptError:
	  print('rotation_spacing.py -f <filename>')
	  sys.exit(2)
	for opt, arg in opts:
	  if opt == '-h':
	     print('rotation_spacing.py -f <filename>')
	     sys.exit()
	  elif opt in ("-f", "--file"):
	     filename = arg

	try:
		# More accurate peak finding from
		# https://gist.github.com/endolith/255291#file-parabolic-py
		from parabolic import parabolic

		def argmax(x):
		    return parabolic(x, numpy.argmax(x))[0]
	except ImportError:
		from numpy import argmax

	#filename = 'other_imgs/img11.tiff'

	# Load file, converting to grayscale
	I = asarray(Image.open(filename).convert('L'))
	I = I - mean(I)  # Demean; make the brightness extend above and below zero
	plt.subplot(2, 2, 1)
	plt.imshow(I)

	# Do the radon transform and display the result
	sinogram = radon(I)

	plt.subplot(2, 2, 2)
	plt.imshow(sinogram.T, aspect='auto')
	plt.gray()

	# Find the RMS value of each row and find "busiest" rotation,
	# where the transform is lined up perfectly with the alternating dark
	# text and white lines
	r = array([rms_flat(line) for line in sinogram.transpose()])
	rotation = argmax(r)
	#print('Rotation: {:.2f} degrees'.format(90 - rotation))

	'''
	rotation = 90 - rotation
	rotation = -rotation
	print('{:.2f}'.format(rotation))
	'''
	print('{:.2f}'.format(-(90-rotation)))
	#plt.axhline(rotation, color='r')

	# Plot the busy row
	row = sinogram[:, rotation]
	N = len(row)
	#plt.subplot(2, 2, 3)
	#plt.plot(row)

	# Take spectrum of busy row and find line spacing
	window = blackman(N)
	spectrum = rfft(row * window)
	#plt.plot(row * window)
	frequency = argmax(abs(spectrum))
	line_spacing = N / frequency  # pixels
	#print('Line spacing: {:.2f} pixels'.format(line_spacing))
	'''
	plt.subplot(2, 2, 4)
	plt.plot(abs(spectrum))
	plt.axvline(frequency, color='r')
	plt.yscale('log')
	plt.show()
	'''

if __name__ == "__main__":
	main(sys.argv[1:])