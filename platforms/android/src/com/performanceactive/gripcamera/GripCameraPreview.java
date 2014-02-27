/**
 *
 */
package com.performanceactive.gripcamera;

import android.content.Context;
import android.hardware.Camera;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

import java.io.IOException;

/**
 *
 */
public class GripCameraPreview extends SurfaceView implements SurfaceHolder.Callback {

    private static final String TAG = GripCameraPreview.class.getSimpleName();

    private final Camera camera;

    public GripCameraPreview(Context context, Camera camera) {
        super(context);
        this.camera = camera;
        getHolder().addCallback(this);
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        try {
            camera.setPreviewDisplay(holder);
            camera.startPreview();
        } catch (IOException e) {
            Log.d(TAG, "Error setting camera preview: " + e.getMessage());
        }
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        camera.stopPreview();
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
//        // If your preview can change or rotate, take care of those events here.
//        // Make sure to stop the preview before resizing or reformatting it.
//
//        if (surfaceHolder.getSurface() == null){
//            return;
//        }
//
//        // stop preview before making changes
//        try {
//            camera.stopPreview();
//        } catch (Exception e){
//            // ignore, tried to stop a non-existent preview
//        }
//
//        // set preview size and make any resize, rotate or
//        // reformatting changes here
//
//        try {
//            camera.setPreviewDisplay(surfaceHolder);
//            camera.startPreview();
//        } catch (Exception e){
//            Log.d(TAG, "Error starting camera preview: " + e.getMessage());
//        }
    }

}
