// var argscheck = require('cordova/argscheck');
// var getValue = argscheck.getValue;

var gripCamera = {
    getPicture: function(filename, success, failure, options) {
        // options = options || {};
        // var quality = getValue(options.quality, 50);
        // var targetWidth = getValue(options.targetWidth, -1);
        // var targetHeight = getValue(options.targetHeight, -1);
        // var correctOrientation = !!options.correctOrientation;

        cordova.exec(success, failure, "GripCamera", "takePicture", [filename]);
    }
};

module.exports = gripCamera;