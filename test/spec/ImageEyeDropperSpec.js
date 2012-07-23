describe("ImageEyeDropper", function() {
	var sampleImage;

	beforeEach(function() {
		sampleImage = document.createElement('img');
		sampleImage.setAttribute('src', '/test/src/sample.jpg');
	});

	it('should be able to obtain color given a point', function() {
		var imageEyeDropper = new ImageEyeDropper(sampleImage);
		waitsFor(function() {
			return imageEyeDropper.isReady();
		}, 'image never loaded', 10000);

		runs(function() {
			var expectedHex = '#d9d6cd';
			var expectedRgb = [217, 214, 205];
			imageEyeDropper.colorFromPoint({x: 0, y: 0});
			expect(imageEyeDropper.rgb).toBeAccurateWithin(1, expectedRgb);

			expectedHex = '#2c2d25';
			expectedRgb = [44, 45, 37];
			imageEyeDropper.colorFromPoint({x: 162, y: 117});
			expect(imageEyeDropper.rgb).toBeAccurateWithin(1, expectedRgb);
		});
	});

});