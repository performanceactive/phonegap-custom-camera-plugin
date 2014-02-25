var GripCamera = {
    getPicture: function(filename, success, failure){
        cordova.exec(success, failure, "GripCamera", "takePicture", [filename]);
    }
};