describe("ImageEyeDropper", function() {
	var sampleImage;

	beforeEach(function() {
		sampleImage = document.createElement('img');
		sampleImage.setAttribute('src', '/test/src/rainbow.png');
	});

	it('should be able to obtain color given a point', function() {
		var imageEyeDropper = new ImageEyeDropper(sampleImage);
		waitsFor(function() {
			return imageEyeDropper.isReady();
		}, 'image never loaded', 10000);

		runs(function() {
			var expectedHex, expectedRgb;
			var accuracy = 1;       // within 1% accuracy

			// top left pixel
			expectedHex = '#ffd300';
			expectedRgb = [255, 211, 0];
			imageEyeDropper.colorFromPoint({x: 0, y: 0});
			expect(imageEyeDropper.rgb).toBeAccurateWithin(accuracy, expectedRgb);

			// top right pixel
			expectedHex = '#ff00e1';
			expectedRgb = [255, 0, 225];
			imageEyeDropper.colorFromPoint({x: 499, y: 0});
			expect(imageEyeDropper.rgb).toBeAccurateWithin(accuracy, expectedRgb);

			// bottom left pixel
			expectedHex = '#00ff33';
			expectedRgb = [0, 255, 51];
			imageEyeDropper.colorFromPoint({x: 0, y: 499});
			expect(imageEyeDropper.rgb).toBeAccurateWithin(accuracy, expectedRgb);

			// bottom right pixel
			expectedHex = '#003bff';
			expectedRgb = [0, 59, 255];
			imageEyeDropper.colorFromPoint({x: 499, y: 499});
			expect(imageEyeDropper.rgb).toBeAccurateWithin(accuracy, expectedRgb);
		});
	});

});