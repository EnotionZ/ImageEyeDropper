beforeEach(function() {
  this.addMatchers({
	// When browser renders image into the canvas, you don't get a 1:1 mapping
	// tests will be based on accuracy
    toBeAccurateWithin: function(accuracy, rgb) {
      var _rgb = this.actual;
	  var delta = Math.sqrt(Math.pow(_rgb[0]-rgb[0],2) + Math.pow(_rgb[1]-rgb[1],2) + Math.pow(_rgb[2]-rgb[2],2));

	  // normalize accuracy value to be on scale of 0-100
	  accuracy *= 2.55;

	  return delta <= accuracy;
    }
  });
});
