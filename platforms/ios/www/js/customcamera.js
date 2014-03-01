var customCamera = {
    getPicture: function(filename, success, failure, options) {
        options = options || {};
        var quality = options.quality || 80;
        cordova.exec(success, failure, "CustomCamera", "takePicture", [filename, quality]);
    }
};

module.exports = customCamera;