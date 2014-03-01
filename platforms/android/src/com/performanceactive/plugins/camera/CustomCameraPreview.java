/**
 *
 */
package com.performanceactive.plugins.camera;

import android.content.Context;
import android.hardware.Camera;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

import java.io.IOException;

/**
 *
 */
public class CustomCameraPreview extends SurfaceView implements SurfaceHolder.Callback {

    private static final String TAG = CustomCameraPreview.class.getSimpleName();

    private final Camera camera;

    public CustomCameraPreview(Context context, Camera camera) {
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
        // only portrait full screen supported
    }

}
