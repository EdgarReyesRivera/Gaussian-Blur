# **Gaussian-Blur**
## Problem Description

This project aims to create a system that allows users to upload an image and selectively blur sections using a mouse connected to an FPGA board. The primary functionality involves implementing a Gaussian blur effect to enhance the image editing process, demonstrating how hardware acceleration can improve computational tasks.

## What is Gaussian blur:

A Gaussian blur is a technique used in image processing to ‘smooth’ out or ‘soften’ an image. It can help reduce noise and detail in a way that the nearby pixels are given greater influence than the farther away ones. It does this by using a mathematical equation called the ‘Gaussian function’.

## What is a Gaussian function?

The Gaussian function is a fancier way to describe a bell shaped curve, it’s purpose in the blur is to decide how much to mix each pixel when creating the blur effect. The center of the curve(the top of the bell) represents your chosen pixel while nearby pixels are closer to the top and get more ‘importance’ when mixing. Lastly, faraway pixels are the lowest on the curve and contribute less to the final mix.
For example, imagine you drop a tiny pebble in a pond. The ripple would be the strongest at the center(the bell’s peak), as you move further and further away from the center the ripple begins to fade. The Gaussian blur does the same thing by deciding how to blend pixels based on how far they are from the center

## The Function: G(x, y) = (1 / (2πσ²)) * e^(-(x² + y²) / (2σ²))


Where :
(x,y)= The distance of a pixel from the center of the line 

σ  = The standard deviation, this controls the ‘spread’ of the blur

e = Eurlers Number (approximately 2.718)

## How does this all work?
Kernel generation: A matrix, or kernel, is created using the Gaussian Function. For example,e a 5x5 kernel will look like a grid with its values being higher at the center and lowering the closer you get to the edges

Convolution: This Kernel is then applied to every pixel in the image. The value of each new pixel becomes the weighted average of the neighboring one.

Smoothing effect: The process blurs the image by softening sharp transitions and spreading pixel intensities in the nearby areas.

### Example:

 Now imagine if you were smudging a pencil line with your finger. The part where you put the most pressure (the center) gets the most smudged, and it fades out the farther away you go. The Gaussian blur works just like this but instead uses math to figure out how much to really smudge each part

 ## Description of Design:

### System Overview
#### 1) The Input: Allows users to upload an image to the FPGA.
#### 2) How to control it:Enables users to select regions of the image for blurring.
#### 3) Image blurring: Applies the Gaussian blur algorithm to the selected regions.

### FPGA Implementation Steps

#### 1) Image Upload: The image is treated as a grid of pixel values and loaded into FPGA-accessible memory.

#### 2) Mouse Integration: A PS/2 mouse interface tracks user clicks and drags to determine the regions to blur.

#### 3) Kernel Multiplication: The FPGA uses a sliding window approach to process 3x3 pixel blocks, multiplying them by the kernel values and summing up the results for each block.

#### 4) Output Data: The blurred pixel values are written back to memory or sent to the display.

#### 5) Pipeline Processing: Registers are used to process one pixel while preparing the next, ensuring smooth operation.

 


